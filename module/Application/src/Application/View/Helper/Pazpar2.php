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

	/**
	 * Paging element
	 * Overrides version in Helper/Search.php to add first/last
     * options. Merge back in later? FIXME
	 * @param int $total 		total # of hits for query
	 * @param int $start 		First record on current page
	 * @param int $max 			maximum number of results to show per page
	 * 
	 * @return DOMDocument formatted paging navigation
	 */
	
	public function pager( $total, $start, $max )
	{
		if ( $total < 1 )
		{
			return null;
		}
		
		$objXml = new \DOMDocument( );
		$objXml->loadXML( "<pager />" );
	
		$base_record = 1; // starting record in any result set
		$page_number = 1; // starting page number in any result set
		$bolShowFirst = false; // show the first page when you get past page 10
		$bolShowLast = false; // show the last page when it's past the numbered range shown
		
		if ( $start == 0 ) 
		{
			$start = 1;
		}
		
		$current_page = (($start - 1) / $max) + 1; // calculates the current selected page
		$bottom_range = $current_page - 4; // used to show a range of pages
		$top_range = $current_page + 4; // used to show a range of pages
		
		$total_pages = ceil( $total / $max ); // calculates the total number of pages
		
		// for pages 1-8 show just 1-8 (or whatever records per page)
		
		if ( $bottom_range < 0 )
		{
			$bottom_range = 0;
		}

		if ( $bottom_range > 2 ) // as we already have the 'previous' link when page=2
        {
			$bolShowFirst = true;
        }

		if ( $current_page < 4 )
		{
			$top_range = 8;
		} 
		
        if ( $total_pages > $top_range )
        {
            $bolShowLast = true;
        }

		// chop the top pages as we reach the end range
		
		if ( $top_range > $total_pages )
		{
			$top_range = $total_pages;
		}
		
		// see if we even need a pager
		
		if ( $total > $max )
		{
			// create pages and links

            if ( $bolShowFirst )
            {
			    $objPage = $objXml->createElement( "page", "|<" );
						
				$params = $this->currentParams();
				$params["start"] = '1';
						
				$link = $this->request->url_for( $params );
						
				$objPage->setAttribute( "link", Parser::escapeXml( $link ) );
				$objPage->setAttribute( "type", "first" );
				$objXml->documentElement->appendChild( $objPage );
			}

			$previous = $start - $max;

            if ( $start > $max )
			{
				$objPage = $objXml->createElement( "page", "<" ); // element to hold the text_results_previous label
				
				$params = $this->currentParams();
				$params["start"] =  $previous;
				
				$link = $this->request->url_for( $params );
				
				$objPage->setAttribute( "link", Parser::escapeXml( $link ) );
				//$objPage->setAttribute( "type", "previous" );
				$objXml->documentElement->appendChild( $objPage );
			}


			while ( $base_record <= $total )
			{
				if ( $page_number >= $bottom_range && $page_number <= $top_range )
				{
					if ( $current_page == $page_number )
					{
						$objPage = $objXml->createElement( "page", $page_number );
						$objPage->setAttribute( "here", "true" );
						$objXml->documentElement->appendChild( $objPage );
					} 
					else
					{
						$objPage = $objXml->createElement( "page", $page_number );
						
						$params = $this->currentParams();
						$params["start"] = $base_record;
						
						$link = $this->request->url_for( $params );
						
						$objPage->setAttribute( "link", Parser::escapeXml( $link ) );
						$objXml->documentElement->appendChild( $objPage );
					
					}
				}
				
				$page_number++;
				$base_record += $max;
			}
			
			$next = $start + $max;
			
			if ( $next <= $total )
			{
				$objPage = $objXml->createElement( "page", ">" ); // element to hold the text_results_next label
				
				$params = $this->currentParams();
				$params["start"] =  $next;
				
				$link = $this->request->url_for( $params );
				
				$objPage->setAttribute( "link", Parser::escapeXml( $link ) );
				//$objPage->setAttribute( "type", "next" );
				$objXml->documentElement->appendChild( $objPage );
			}

            if ( $bolShowLast )
            {
			    $objPage = $objXml->createElement( "page", ">|" );
						
				$params = $this->currentParams();
				$params["start"] = $total - $max + 1;
						
				$link = $this->request->url_for( $params );
						
				$objPage->setAttribute( "link", Parser::escapeXml( $link ) );
				//$objPage->setAttribute( "type", "last" );
				$objXml->documentElement->appendChild( $objPage );
			}

		}
		
		return $objXml;
	}
	
}

?>
