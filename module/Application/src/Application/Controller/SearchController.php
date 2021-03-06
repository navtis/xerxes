<?php

namespace Application\Controller;

use Application\View\Helper\Search as SearchHelper,
	Application\Model\Search\Query,
	Application\Model\Search\Result,
	Application\Model\DataMap\SavedRecords,
	Xerxes\Record,
	Xerxes\Utility\Parser,
	Xerxes\Utility\Registry,
	Zend\Mvc\Controller\ActionController,
	Zend\Mvc\MvcEvent;

abstract class SearchController extends ActionController
{
	protected $id = "search";
	
	protected $registry; // registry
	protected $config; // local config
	protected $query; // query object
	protected $engine; // search engine
	protected $helper; // search display helper

	protected $max; // default records per page
	protected $max_allowed; // upper-limit per page
	protected $sort; // default sort
	
	protected $data = array(); // response data
	
	public function execute(MvcEvent $e)
	{
		$this->init($e);
		parent::execute($e);
	}
	
	protected function init(MvcEvent $e)
	{
		$this->engine = $this->getEngine();
		
		$this->config = $this->engine->getConfig();
		
		$this->registry = Registry::getInstance();
		
		$this->data["config_local"] = $this->config->toXML();
		
		$this->query = $this->engine->getQuery($this->request);
		
		$this->helper = new SearchHelper($e, $this->id, $this->engine);
	}
	
	abstract protected function getEngine();
	
	public function indexAction()
	{
		return $this->data;
	}
	
	public function searchAction()
	{
		// set the url params for where we are gong to redirect,
		// usually to the results action, but can be overriden
		
		$base = $this->helper->searchRedirectParams();
		$params = $this->query->getAllSearchParams();
		$params = array_merge($base, $params);
		
		// check spelling
		
		$this->checkSpelling();
		
		// construct the actual url and redirect

		$url = $this->request->url_for($params);
		
		return $this->redirect()->toUrl($url);
	}
	
	public function hitsAction()
	{
		// create an identifier for this search
		
		$id = $this->helper->getQueryID();
		
		// see if one exists in session already
		
		$total = $this->request->getSessionData($id);
		
		// nope
		
		if ( $total == null )
		{
			// so do a search (just the hit count) 
			// and cache the hit total
			
			$total = $this->engine->getHits($this->query);
			$this->request->setSessionData($id, (string) $total);
		}
		
		// format it 
		
		$total = Parser::number_format($total);
		
		// and tell the browser too
		
		$this->data["hits"] = $total;
		return $this->data;
	}
	
	public function resultsAction()
	{
		// defaults
		
		$this->max = $this->registry->getConfig("RECORDS_PER_PAGE", false, 10);
		$this->max = $this->config->getConfig("RECORDS_PER_PAGE", false, $this->max);
		
		$this->max_allowed = $this->registry->getConfig("MAX_RECORDS_PER_PAGE", false, 30);
		$this->max_allowed = $this->config->getConfig("MAX_RECORDS_PER_PAGE", false, $this->max_allowed);
		
		$this->sort = $this->registry->getConfig("SORT_ORDER", false, "relevance");
		$this->sort = $this->config->getConfig("SORT_ORDER", false, $this->sort);
		
		// params
		
		$start = $this->request->getParam('start', 1);
		$max = $this->request->getParam('max', $this->max);
		$sort = $this->request->getParam('sort', $this->sort);
		
		// swap for internal
		
		$internal_sort = $this->config->swapForInternalSort($sort);
		
		// make sure records per page does not exceed upper bound
		
		if ( $max > $this->max_allowed )
		{
			$max = $this->max_allowed;
		}
		
		// search
				
		$results = $this->engine->searchRetrieve($this->query, $start, $max, $internal_sort);
		
		// total
		
		$total = $results->getTotal();
		
		// check spelling
		
		if ( $start <= 1 ) // but only on page 1
		{
			$suggestion = $this->checkSpelling();
			
			$this->helper->addSpellingLink($suggestion);
			$this->data["spelling"] = $suggestion;
		}
		
		// track the query
		
		$id = $this->helper->getQueryID();		
		
		if ( $this->request->getSessionData("stat-$id") == "" ) // first time only, please
		{
			// log it
			// @todo: make this an event
			
			try
			{
				$log = new \Application\Model\DataMap\Stats();
				$log->logSearch($this->id, $this->query, $results);
			}
			catch ( \Exception $e ) // make it a warning so we don't stop the search
			{
				trigger_error('search stats warning: ' . $e->getMessage(), E_USER_WARNING);
			}
			
			// mark we've saved this search log
			
			$this->request->setSessionData("stat-$id", (string) $total);
		
			// cache it
			
			$this->request->setSessionData($id, (string) $total);
		}
		
		
		// add links
		
		$this->helper->addRecordLinks($results);
		$this->helper->addFacetLinks($results);
		$this->helper->addQueryLinks($this->query);
		
		// summary, sort & paging elements
		
		$results->summary = $this->helper->summary($total, $start, $max);
		$results->pager = $this->helper->pager($total, $start, $max);
		$results->sort_display = $this->helper->sortDisplay($sort);
		
		// response
		
		$this->data["query"] = $this->query;
		$this->data["results"] = $results;
		
		return $this->data;
	}
	
	public function recordAction()
	{
		$id = $this->request->getParam('id');

		// get the record

		$results = $this->engine->getRecord($id);
		
		// set links
		
		$this->helper->addRecordLinks($results);
		
		// add to response
		
		$this->data["results"] = $results;
		
		return $this->data;
	}
	
	public function lookupAction()
	{
		$id = $this->request->getParam("id");
		
		// we essentially create a mock object and add holdings
		
		$xerxes_record = new Record();
		$xerxes_record->setRecordID($id);
		$xerxes_record->setSource($this->id);
		
		$result = new Result($xerxes_record, $this->config);
		$result->fetchHoldings();
		
		// add to response
		
		$this->data["results"] = $result;
		
		return $this->data;
	}	

	public function saveAction()
	{
		$datamap = new SavedRecords();
		
		$username = $this->request->getSessionData("username");
		$original_id = $this->request->getParam("id");

		$inserted_id = ""; // internal database id
		
		// delete command
		
		if ( $this->isMarkedSaved( $original_id ) == true )
		{
			$datamap->deleteRecordBySource( $username, $this->id, $original_id );
			$this->unmarkSaved( $original_id );
			$this->data["delete"] = "1";
		}

		// add command
		
		else
		{
			// get record
			
			$record = $this->engine->getRecord($original_id)->getRecord(0)->getXerxesRecord();
			
			// save it
			
			$inserted_id = $datamap->addRecord( $username, $this->id, $original_id, $record );
			
			// record this in session
				
			$this->markSaved( $original_id, $inserted_id );
			
			$this->data["savedRecordID"] = $inserted_id;
		} 
		
		return $this->data;
	}
	
	/**
	 * Check for mispelled terms
	 * 
	 * @param Query $query
	 * @return Suggestion
	 */
	
	protected function checkSpelling()
	{
		$id = $this->helper->getQueryID();
		
		// have we checked it already?
		
		$suggestion = $this->request->getSessionData("spelling_$id");
		
		if ( $suggestion == null ) // nope
		{
			$suggestion = $this->query->checkSpelling(); // check it
			
			$this->request->setSessionData("spelling_$id", serialize($suggestion)); // save for later
		}
		else
		{
			$suggestion = unserialize($suggestion); // resurrect it, like shane
		}
		
		return $suggestion;
	}
	
	
	########################
	#  SAVED RECORD STATE  #
	########################	
	
	
	/**
	 * Store in session the fact this record is saved
	 *
	 * @param string $original_id		original id of the record
	 * @param string $saved_id		the internal id in the database
	 */ 
	
	protected function markSaved( $original_id, $saved_id )
	{
		$data = $this->request->getSessionData('resultsSaved');
		
		if ( $data == null )
		{
			$data = array();
		}
		
		$data[$original_id]['xerxes_record_id'] = $saved_id;
		$this->request->setSessionData('resultsSaved', $data);
	}

	/**
	 * Delete from session the fact this record is saved
	 *
	 * @param string $original_id		original id of the record
	 */ 
	
	protected function unmarkSaved( $original_id )
	{
		$results_saved = $this->request->getSessionData('resultsSaved');
		
		if ( is_array($results_saved ) )
		{
			if ( array_key_exists( $original_id, $results_saved ) )
			{
				unset($results_saved[$original_id]);
				$this->request->setSessionData('resultsSaved', $results_saved);
			}
		}
	}

	/**
	 * Determine whether this record is already saved in session
	 *
	 * @param string $original_id		original id of the record
	 */ 
	
	protected function isMarkedSaved($original_id)
	{
		$results_saved = $this->request->getSessionData('resultsSaved');
		
		if ( is_array($results_saved ) )
		{
			if ( array_key_exists( $original_id, $results_saved ) )
			{
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Get the number of records saved in session
	 */ 
	
	protected function numMarkedSaved()
	{
		$num = 0;
		
		$results_saved = $this->request->getSessionData('resultsSaved');
		
		if ( is_array($results_saved ) )
		{
			$num = count($results_saved);
		}
		
		return $num;
	}
}
