<?php

namespace Application\Model\Summon;

use Application\Model\Search,
	Xerxes\Summon,
	Xerxes\Utility\Factory,
	Xerxes\Utility\Parser,
	Xerxes\Utility\Request;

/**
 * Summon Search Engine
 * 
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Solr
 */

class Engine extends Search\Engine 
{
	protected $summon_client; // summon client
	protected $formats_exclude = array(); // formats configured to exclude

	/**
	 * Constructor
	 */
	
	public function __construct()
	{
		parent::__construct();
		
		$id = $this->config->getConfig("SUMMON_ID", true);
		$key = $this->config->getConfig("SUMMON_KEY", true);		
				
		$this->summon_client = new Summon($id, $key, Factory::getHttpClient());
		
		// @todo: only for local users?
		
		$this->summon_client->setToAuthenticated(); 
		
		// formats to exclude
		
		$this->formats_exclude = explode(',', $this->config->getConfig("EXCLUDE_FORMATS") );
	}
	
	/**
	 * Return the total number of hits for the search
	 * 
	 * @return int
	 */	
	
	public function getHits( Search\Query $search )
	{
		// get the results
		
		$results = $this->doSearch( $search, 1, 0 );

		// return total
		
		return $results->getTotal();
	}

	/**
	 * Search and return results
	 * 
	 * @param Query $search		search object
	 * @param int $start							[optional] starting record number
	 * @param int $max								[optional] max records
	 * @param string $sort							[optional] sort order
	 * 
	 * @return Results
	 */	
	
	public function searchRetrieve( Search\Query $search, $start = 1, $max = 10, $sort = "")
	{
		$results = $this->doSearch( $search, $start, $max, $sort);
		
		$results->markFullText();
		
		return $results;
	}	
	
	/**
	 * Return an individual record
	 * 
	 * @param string	record identifier
	 * @return Results
	 */
	
	public function getRecord( $id )
	{
		// get result
		
		$results = $this->doGetRecord( $id );
		
		$results->getRecord(0)->addRecommendations(); // bx
		$results->markFullText(); // sfx data
		$results->markRefereed(); // refereed
		
		return $results;
	}

	/**
	 * Get record to save
	 * 
	 * @param string	record identifier
	 * @return int		internal saved id
	 */	
	
	public function getRecordForSave( $id )
	{
		return $this->doGetRecord($id);
	}
	
	/**
	 * Do the actual fetch of an individual record
	 * 
	 * @param string	record identifier
	 * @return Results
	 */	
	
	protected function doGetRecord( $id )
	{
		// get result
		
		$summon_results = $this->summon_client->getRecord($id);
		$results = $this->parseResponse($summon_results);
		
		return $results;
	}		
	
	/**
	 * Do the actual search
	 * 
	 * @param Query $search		search object
	 * @param int $start							[optional] starting record number
	 * @param int $max								[optional] max records
	 * @param string $sort							[optional] sort order
	 * 
	 * @return Results
	 */		
	
	protected function doSearch( Search\Query $search, $start = 1, $max = 10, $sort = "")
	{ 	
		// prepare the query
		
		$query = $search->toQuery();
		
		// facets to include in the response
		
		$facets_to_include = array();
		
		foreach ( $this->config->getFacets() as $facet_config )
		{
			$facets_to_include[(string) $facet_config["internal"]] = (string) $facet_config["internal"] . 
				",or,1," . (string) $facet_config["max"]; 
		}
		
		// limits
		
		$facets = array();
		
		foreach ( $search->getLimits(true) as $limit )
		{
			// remove chosen facet from response
			// @todo: make multi-value facets selectable 
			
			$facets_to_include = Parser::removeFromArray($facets_to_include, $limit->field);
			
			array_push($facets, $limit->field . "," . str_replace(',', '\,', $limit->value) . ",false");
		}
		
		// set actual response facets
		
		$this->summon_client->setFacetsToInclude($facets_to_include);

		// filter out formats
		
		foreach ( $this->formats_exclude as $format )
		{
			array_push($facets, "ContentType,$format,true");
		}
		
		// holdings only
		
		if ( $search->isHoldingsOnly() )
		{
			$this->summon_client->limitToHoldings();
		}
		
		// summon deals in pages, not start record number
		
		if ( $max > 0 )
		{
			$page = ceil ($start / $max);
		}
		else
		{
			$page = 1;
		}
		
		// get the results
		
		$summon_results = $this->summon_client->query($query, $facets, $page, $max, $sort);
		
		return $this->parseResponse($summon_results);
	}
	
	/**
	 * Parse the summon response
	 *
	 * @param array $summon_results		summon results array from client
	 * @return ResultSet
	 */
	
	protected function parseResponse($summon_results)
	{
		// testing
		// header("Content-type: text/plain"); print_r($summon_results); exit;	

		// nada
		
		if ( ! is_array($summon_results) )
		{
			throw new \Exception("Cannot connect to Summon server");
		}		
		
		// just an error, so throw it
		
		if ( ! array_key_exists('recordCount', $summon_results) && array_key_exists('errors', $summon_results) )
		{
			$message = $summon_results['errors'][0]['message'];
			
			throw new \Exception($message);
		}
		
		// results
		
		$result_set = new ResultSet($this->config);
		
		
		// recommendations
		
		$databases = $this->extractRecommendations($summon_results);
		
		foreach ( $databases as $database )
		{
			$result_set->addRecommendation($database);
		}

		// total
		
		$total = $summon_results['recordCount'];
		$result_set->total = $total;
		
		// extract records
		
		foreach ( $this->extractRecords($summon_results) as $xerxes_record )
		{
			$result_set->addRecord($xerxes_record);
		}
		
		// extract facets
		
		$facets = $this->extractFacets($summon_results, $total);	 ############## HACK	
		$result_set->setFacets($facets);
		
		return $result_set;
	}

	/**
	 * Parse out database recommendations
	 * 
	 * @param array $summon_results
	 * @return array of Database's
	 */
	
	protected function extractRecommendations($summon_results)
	{
		$databases = array();
		
		$recommendations = $summon_results['recommendationLists'];
		
		if ( array_key_exists('database', $recommendations) )
		{
			foreach ( $recommendations['database'] as $database_array )
			{
				$databases[] = new Database($database_array);
			}
		}		
		
		return $databases;
	}
	
	/**
	 * Parse records out of the response
	 *
	 * @param array $summon_results
	 * @return array of Record's
	 */
	
	protected function extractRecords($summon_results)
	{
		$records = array();
		
		if ( array_key_exists("documents", $summon_results) )
		{
			foreach ( $summon_results["documents"] as $document )
			{
				$xerxes_record = new Record();
				$xerxes_record->load($document);
				array_push($records, $xerxes_record);
			}
		}
		
		return $records;
	}
	
	/**
	 * Parse facets out of the response
	 *
	 * @param array $summon_results
	 * @return Facets
	 */	
	
	protected function extractFacets($summon_results, $total)
	{
		$facets = new Search\Facets();
		
		if ( array_key_exists("facetFields", $summon_results) )
		{		
			// @todo: figure out how to factor out some of this to parent class
			
			// take them in the order defined in config
				
			foreach ( $this->config->getFacets() as $group_internal_name => $config )
			{
				foreach ( $summon_results["facetFields"] as $facetFields )
				{
					if ( $facetFields["displayName"] == $group_internal_name)
					{
						$group = new Search\FacetGroup();
						$group->name = $facetFields["displayName"];
						$group->public = $this->config->getFacetPublicName($facetFields["displayName"]);
							
						$facets->addGroup($group);
						
						// choice type
						
						if ( (string) $config["type"] == "choice")
						{
							foreach ($config->choice as $choice )
							{
								foreach ( $facetFields["counts"] as $counts )
								{
									if ( $counts["value"] == (string) $choice["internal"] )
									{
										$facet = new Search\Facet();
										$facet->name = (string) $choice["public"];
										$facet->count = $counts["count"];
										$facet->key = $counts["value"];
										
										$group->addFacet($facet);
									}
								}
							}
						}
						else // regular
						{
							foreach ( $facetFields["counts"] as $counts )
							{
								// skip excluded facets
								
								if ( $group->name == 'ContentType' && in_array($counts["value"], $this->formats_exclude) )
								{
									continue;
								}
								
								$facet = new Search\Facet();
								$facet->name = $counts["value"];
								$facet->count = $counts["count"];
									
								$group->addFacet($facet);
							}
						}
					}
				}
			}
		}
		
		return $facets;
	}
	
	/**
	 * Return the search engine config
	 *
	 * @return Config
	 */
	
	public function getConfig()
	{
		return Config::getInstance();
	}	
	
	/**
	 * Return the Solr search query object
	 *
	 * @return Query
	 */
	
	public function getQuery(Request $request )
	{
		if ( $this->query instanceof Query )
		{
			return $this->query;
		}
		else
		{
			return new Query($request, $this->getConfig());
		}
	}
}
