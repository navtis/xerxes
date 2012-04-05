<?php

namespace Application\View\Helper;

use Xerxes\Record,
    Xerxes\Utility\Parser,
    Application\Model\Search\Query,
    Application\Model\Search\Result,
    Application\Model\Search\ResultSet;

class Pazpar2 extends Search
{

    public function facetParams()
    {
        $params = $this->currentParams();
        $params['action'] = 'search';

        return $params;
    }

    /** 
    * URL for the full record display, including targets 
    * 
    * @param $result Record object 
    * @return string url 
    */ 
    public function linkFullRecord( Record $result ) 
    { 
        $arrParams = array( 
            'controller' => $this->request->getParam('controller'), 
            "action" => "record", 
            "id" => $result->getRecordID(), 
            'target' => $this->request->getParam('target', null, true) 
        ); 
        return $this->request->url_for($arrParams); 
    } 
    /** 
    * URL for the record display, with no target yet specified
    * 
    * @param $result Record object 
    * @return string url 
    */
    public function linkOther( Result $result ) 
    {
        $record = $result->getXerxesRecord();
        $arrParams = array( 
            'controller' => $this->request->getParam('controller'), 
            "action" => "record", 
            "id" => $record->getRecordID()
        ); 
        $result->url_for_item = $this->request->url_for($arrParams); 
        return $result;
    } 
  
	/**
	 * Add links to facets
	 * 
	 * @param ResultSet $results
	 */	
	
	public function addFacetLinks( ResultSet &$results )
	{	
		// facets

		$facets = $results->getFacets();
		
		if ( $facets != "" )
		{
			foreach ( $facets->getGroups() as $group )
			{
				foreach ( $group->getFacets() as $facet )
				{
					// existing url
						
					$url = $this->facetParams();
							
					// now add the new one
							
					if ( $facet->key != "" ) 
					{
						// key defines a way to pass the (internal) value
						// in the param, while the name is the display value
					    // NB different behavious from other Xerxes apps
						$url["facet." . $group->name] = urlencode($facet->key);
					}
					else
					{
						$url["facet." . $group->name] = $facet->name;									
					}
					$facet->url = $this->request->url_for($url);
				}
			}
		}
	}

   /**
    * Make removing facet links generate a new search
    * by overriding links assigned by parent 
    * @param $query Query object
    */
    public function addQueryLinks(Query $query)
    {
        parent::addQueryLinks($query);

        foreach ( $query->getLimits() as $limit )
        {
            $params = $this->currentParams();
            $params = Parser::removeFromArray($params, $limit->field, $limit->value);
            $params['action'] = 'search';
            $limit->remove_url = $this->request->url_for($params);
        }
    }

}

?>
