<?php

namespace Application\Model\Pazpar2;

use Application\Model\DataMap\Pz2Targets,
	Application\Model\Search,
    Zend\Debug,
	Xerxes\Utility\Request;

/**
 * Search Query
 *
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Query extends Search\Query
{
	protected $date; // timestamp of query
	protected $targetnames = array(); // shortnames for targets
	protected $targets = array(); // Targets
	protected $datamap; // data map

    public function __construct(Request $request = null, Config $config = null )
    {
        parent::__construct($request, $config );
        //Debug::dump($request);
        $this->targetnames = $request->getParam('target', null, true);
        //Debug::dump($this->targetnames);
    }

	/**
	 * Flesh out the request with target information from KB
	 * 
	 * @throws \Exception
	 */
	
	public function fillTargetInfo()
	{
		// make sure we got some terms!
		if ( count($this->getQueryTerms()) == 0 )
		{
			throw new \Exception("No search terms supplied");
		}
		
		// libraries chosen
		
        // FIXME fix library/Xerxes/Utility/Request.php to handle arrays properly
		//$targets = $this->request->getParam('target%5B%5D', null, true);
		// populate the target information from KB
		$this->datamap = new Pz2Targets(); // @todo: use KB model instead?
		
		if ( count($this->targetnames) >= 0 )
		{
			$this->targets = $this->datamap->getTargets($this->targetnames);
		}
	    else	
		{
			throw new \Exception("No libraries selected for search");
		}
        return $this->targets;
	}
    /** 
    * Extract query, limit and target params from the URL 
    * @return array 
    */ 
    public function getAllSearchParams() 
    {
        $lq = parent::getAllSearchParams();
		$lq['target'] = $this->targetnames;
        //Debug::Dump($lq);
        return $lq;
    }


	/**
     * FIXME NEEDS ADAPTING
	 * Convert the search terms to Pazpar2 query
	 */
	
	public function toQuery()
	{
		// construct query
		
		$query = "";
		
		$terms = $this->getQueryTerms();

		//var_dump($terms); exit;
		// normalize terms
		
		$term = $terms[0];
		$term->toLower()->andAllTerms();
		
	    $phrase = urlencode( trim ( $term->phrase ) );	
        
        if ($term->field_internal == 'any') // default
        {
            $query = $phrase;
        }
        else
        {
			
			$query = $term->field_internal . "=" . $phrase ;
		}
		return $query;
	}
	
	/**
	 * Get all targets
	 * 
	 * @return array of Target objects
	 */
	
	public function getTargets()
	{
		return $this->targets;
	}
	/**
	 * Get all target pazpar2 IDs
	 * 
	 * @return array of Target Ids
	 */
	
	public function getTargetIDs()
	{
        $tids = array();
		foreach($this->targets as $target)
        {
            $tids[] = $target->pz2_zurl;
        }
        return $tids;
            
	}
	
	/**
	 * Get searchable target IDs
	 * 
	 * @return array
	 */
/*	// FIXME not needed???
	public function getSearchableTargets()
	{
		
		$targets_to_search = array();
		
		foreach ( $this->targets as $target_object )
		{
			$targets_to_search[] = $target_object->target_id; 
		}
		
		return $targets_to_search;
	}
*/	
	/**
	 * Get selected region
	 */
/* FIXME query doesn't need to know about regions 	
	public function getRegion()
	{
		return $this->request->getParam('region');
	}
*/	
	/**
	 * Get selected language
	 */
	
	public function getLanguage()
	{
		return $this->request->getParam('lang');
	}
	public function getSession()
	{
		return $this->request->getParam('session');
	}
}
