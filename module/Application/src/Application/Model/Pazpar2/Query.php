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
		// populate the target information from KB
		$this->datamap = new Pz2Targets($this->targetnames); 
		
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
        // ANDing a long list of terms makes this an invalid Z39.50 query
		//$term->toLower()->andAllTerms();
	
        // remove punctuation
        $phrase = preg_replace('/[\W]+/', ' ', $term->phrase);
        // tidy multiple spaces
        $phrase = preg_replace('/[\s]+/', ' ', $term->phrase);

	    $phrase = urlencode( trim ( $phrase ) );	
        
        if ($term->field_internal == 'any') 
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
	 * Get target pz2_names
	 * 
	 * @return array of strings
	 */
	
	public function getTargetnames()
	{
		return $this->targetnames;
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
	
	public function getLanguage()
	{
		return $this->request->getParam('lang');
	}
	public function getSession()
	{
		return $this->request->getParam('session');
	}
}
