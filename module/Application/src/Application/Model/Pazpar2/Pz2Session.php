<?php

namespace Application\Model\Pazpar2;

use Zend\Session\Container,
    Application\Model\Authentication\User,
	Application\Model\Knowledgebase\Pz2Target,
    Application\Model\Search,
	Xerxes\Pazpar2,
	Xerxes\Utility\Cache,
	Xerxes\Utility\Factory,
	Xerxes\Utility\Parser,
    Zend\Debug,
	Xerxes\Utility\Xsl;


/**
 * Pazpar2 Search Session
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2012 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Pz2Session
{
	protected $date; // date search was initialized
	protected $sid; // pazpar2-supplied session id; this object has reference copy	
	protected $result_set; // merged result set
	protected $included_libraries = array(); // libraries included in the search
    protected $query;	
	protected $config; // pz2 config
	protected $client; // pz2 client
	protected $cache; // cache


	public function __sleep()
	{
		// don't include config & cache
        // FIXME why?? GS
		
		return Parser::removeProperties(get_object_vars($this), array('config', 'cache'));
	}
	
	/**
	 * Initiate the search with pazpar2 for this set of targets
	 */
	
	public function initiateSearch(Query $query)
	{
		// flesh out target information from the kb
		$query->fillTargetInfo();

        // FIXME can't serialize if $query stored here- why?
		// $this->query = $query; 

        if (isset( $query->limits ) && (sizeof( $query->limits ) > 0 ) )
        {
            $terms = array();
            foreach($query->limits as $limit_term)
            {
                $facets[] = urlencode( preg_replace('/facet\./', '', $limit_term->field) . $limit_term->relation . $limit_term->value );    
            }                                                                    
        }
        else
        {
            $facets = null;
        }
		$maxrecs = $this->config()->getConfig('MAXRECS', false);
		// start the search
        $this->client()->search( $query->toQuery(), $query->getTargetIDs(), $facets, $maxrecs );
        // save the session id for this search
		$this->sid = $this->client->session; // Client may have created new sid
        // store the sid in $_SESSION to be available for later requests
        $sess = new Container('pazpar2');
        $sess->sid = $this->client->session;
		
		// register the date
		
		$this->date = $this->getSearchDate();
	}
	
	/**
	 * Check the status of the search
	 * 
	 * @return Status
	*/
	
	public function getSearchStatus()
	{
		$status = new Status();
		
		// get latest statuses from pazpar2 as a hash
	
        $result = $this->client()->pz2_bytarget($this->getId());

        $status->setXml( $result['xml'] );
        unset( $result['xml'] );
		
        foreach($result as $k => $v)
        {
			$status->addTargetStatus($v);
		}
		
		// see if search is finished
		// FIXME redundant call to pz2_stat - simplify
		$status->setFinished($this->client()->isFinished($this->getId()));
		$status->setProgress($this->client()->getProgress($this->getId()));
		
		return $status;
	}
	
	/**
	 * Merge the search results
	 * FIXME modify to handle facets but without merge, which is done by pz2. Rename would be good.
	 * @param string $sort			sort order
	 * 
	 * @return Status
	 */
	
	public function merge($start=0, $max=100, $sort = null, $targets)
	{
        $results = $this->client->pz2_show($this->getId(), $start, $max, $sort);

         //Debug::dump($results);
         
         $this->result_set = new MergedResultSet($results, $targets);

		// fetch facets
		// only if we should show facets and there are more than 15 results
			
		if ( $this->result_set->total > 15  && $this->config()->getConfig('FACET_FIELDS', false) == true )
		{
			$terms = array('author', 'subject'); // FIXME put in config 
			$xml = $this->client()->pz2_termlist( $this->getId(), $terms );
            //echo("facets: ".$xml->saveXML());
            $facets = $this->extractFacets($xml);
            $this->result_set->setFacets($facets);
		}
		
		return $this->result_set;
	}

    // COPY AND PASTE FROM PRIMO ENGINE (with small mods)
    // AS DONT OTHERWISE KNOW HOW TO MUNGE TERMLIST INTO GENERIC XERXES FACETS
    /**
     * Parse facets out of the response
     *
     * @param DOMDocument $dom  pazpar2 XML
     * @return Facets
     */

     protected function extractFacets(\DOMDocument $dom)
     {
        $facets = new Search\Facets();

       // echo $dom->saveXML();

        $groups = $dom->getElementsByTagName("list");

        if ( $groups->length > 0 )
        {
            // we'll pass the facets into an array so we can control both which 
            // ones appear and in what order in the Xerxes config

            $facet_group_array = array();

            foreach ( $groups as $facet_group )
            {
                $facet_values = $facet_group->getElementsByTagName("term");

                // if only one entry, then all the results have this same facet, 
                // so no sense even showing this as a limit 
                if ( $facet_values->length <= 1 ) 
                { 
                    continue;
                } 
                $group_internal_name = $facet_group->getAttribute("name"); 
                $facet_group_array[$group_internal_name] = $facet_values; 
            } 
            // now take the order of the facets as defined in xerxes config 
            foreach ( $this->config->getFacets() as $group_internal_name => $facet_values )
            { 
                // we defined it, but it's not in the pazpar2 response 
                if ( ! array_key_exists($group_internal_name, $facet_group_array) ) 
                { 
                    continue; 
                }

                $group = new Search\FacetGroup(); 
                $group->name = $group_internal_name; 
                $group->public = $this->config->getFacetPublicName($group_internal_name); 
                // get the actual facets out of the array above 
                $facet_values = $facet_group_array[$group_internal_name]; 
                // and put them in their own array so we can mess with them 
                $facet_array = array(); 
                foreach ( $facet_values as $facet_value ) 
                { 
                    $name = $facet_value->getElementsByTagName("name")->item(0)->nodeValue;
                    // for some reason pz2 returns authors with a trailing comma
                    // sometime also get unwanted fullstop
                    $name = trim($name, ",. "); 
                    $counts = $facet_value->getElementsByTagName("frequency");
                    $count = $counts->item(0)->nodeValue;
                    $facet_array[$name] = $count;
                } 
                // date 
                $decade_display = array(); 
                $is_date = $this->config->isDateType($group_internal_name); 
                if ( $is_date == true ) 
                { 
                    // FIXME
                    $date_arrays = $group->luceneDateToDecade($facet_array); 
                    $decade_display = $date_arrays["display"]; 
                    $facet_array = $date_arrays["decades"]; 
                } 
                else 
                { 
                    // not a date, sort by hit count 
                    arsort($facet_array); 
                }

                // sort facets into descending order of frequency
                arsort($facet_array); // assume not date

                // now make them into group facet objects 
                foreach ( $facet_array as $key => $value ) 
                { 
                    $public_value = $this->config->getValuePublicName($group_internal_name, $key); 
                    $facet = new Search\Facet(); 
                    $facet->name = $public_value; 
                    $facet->count = $value;
                    // dates are different 
                    if ( $is_date == true ) 
                    { 
                        $facet->name = $decade_display[$key]; 
                        $facet->is_date = true; 
                        $facet->key = $key; 
                    } 
                    $group->addFacet($facet); 
                } 
                $facets->addGroup($group); 
            } 
        } 
        return $facets; 
    } 


	/**
	 * Return an individual record
     *
	 * @param string	record identifier
     * @param array     offset values for each holding
     * @param target    pz2_key for target
	 * @return Results
	 */
	
	public function getRecord( $id, $offset=null, $targets )
    {
        // recover sid from Zend session
        $sid = Pz2Session::getSavedId();
        $record = $this->client()->pz2_record( $sid, $id, $offset ); 

        // need to return a ResultSet, record is a DomDocument
        if ( ! is_null($offset) ) 
        {
            // FIXME MarcRecord and Offset not yet implemented
            $xerxes_record = new MarcRecord(); // convert to xerxes record format first
            $xerxes_record->loadXML( $record );
        } 
        else
        {
            // keep MergedResultSet happy by making it look like single result
            $results = array();
            $results['hits'] = array();
            $results['start'] = 0;
            $results['merged'] = 1; 
            $results['hits'][0] = $record->saveXML();
            $this->config = Config::getInstance();
		    $useCopac = $this->config()->getConfig('USECOPAC', false);
            if ( $useCopac )
            {
                // SEARCH25-specific option
                $result_set = new CopacMergedResultSet($results, $targets);
            }
            else
            {   // normal default
                $result_set = new MergedResultSet($results, $targets);
            }
        }
      
        return $result_set;
    }

	/**
	 * Get facets
	 */
	
	public function getFacets()
	{
		return $this->cache()->get("facets-" . $this->getId());
	}
	
	/**
	 * Lazyload Pazpar2 Client
	 */
	
	public function client()
	{
		if ( ! $this->client instanceof Pazpar2 )
		{
			$this->client = Engine::getPazpar2Client(); 
		}
		return $this->client;
	}
	
	/**
	 * Lazyload Config
	 */
	
	protected function config()
	{
		if ( ! $this->config instanceof Config )
		{
			$this->config = Config::getInstance();
		}
	
		return $this->config;
	}
	
	/**
	 * Lazyload Cache
	 */
	
	protected function cache()
	{
		if ( ! $this->cache instanceof Cache )
		{
			$this->cache = new Cache();
		}
	
		return $this->cache;
	}	
	
	/**
	 * Calculate search date based on current time
	 */
	
	protected function getSearchDate()
	{
		$time = time();
		return date("Y-m-d", $time);
	}
	
	/**
	 * Pz2 Session ID
	 */
	
	public function getId()
	{
        if ( isset( $this->sid ) )
        {
            return $this->sid;
        }
        else
        {
            $sess = new Container('pazpar2');
            $this->sid = $sess->sid; 
            return $this->sid;
        }
	}
    // Static version for use when no Sessionobject available
    // and don't want overhead of creating a throwaway one
	public static function getSavedId()
	{
        $sess = new Container('pazpar2');
        return $sess->sid; 
	}
}
