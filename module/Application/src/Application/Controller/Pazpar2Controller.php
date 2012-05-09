<?php

namespace Application\Controller;

use Application\Model\Pazpar2\Engine,
    Application\Model\DataMap\Pz2Targets,
    Application\Model\DataMap\SavedRecords,
    Application\View\Helper\Pazpar2 as SearchHelper,
    Zend\Mvc\MvcEvent,
    Zend\Debug,
    Zend\Mvc\Controller\Plugin\FlashMessenger;

class Pazpar2Controller extends SearchController
{
	protected $id = "pazpar2";
    protected $fm; // flashMessenger

    protected function init(MvcEvent $e)
    {
        parent::init($e);
        $this->helper = new SearchHelper($e, $this->id, $this->engine);
        // FIXME should this use a broker? Can't work out how (or why)
        $this->fm = new FlashMessenger();
    }

    protected function getEngine()
    {
        return new Engine();
    }

    public function indexAction()
    {
        // if sent back here by exception, display any message
        // done automatically?
        //$this->data['messages'] = $this->fm->getMessages();
        //Debug::dump($this->query); exit;
        //Debug::dump($this->getEngine()); exit;
        $targets = is_array($this->query->getTargetNames() )?$this->query->getTargetNames(): array();
        //var_dump($targets); exit;
        $this->data['regions'] = $this->engine->getRegions( $targets );
        //echo ($this->data['regions']->toXml()->saveXML() ); exit;
       // Debug::dump($regions ); exit;
        return($this->data);
    }

    public function libraryAction()
    {
        $targets = is_array($this->query->getTargetNames() )?$this->query->getTargetNames(): array('GENERAL');
        $this->data['target'] = $this->engine->getTarget($targets[0]);
        //echo($this->data['target']->toXML()->saveXML()); exit;
        return($this->data);
    }

    /* called only from the search box - a brand new search */
	public function startsessionAction()
    {
        // initialise the session for a new search
        $sid = $this->engine->initializePazpar2Client();
        //$ns = new Zend_Session_Namespace($this->id);
        //$ns->sid = $sid;
        $_SESSION[$this->id]['sid'] = $sid;
		// then  redirect to search action
        $params = $this->query->getAllSearchParams();
		$params['lang'] = $this->request->getParam('lang');
	    $params['controller'] = $this->request->getParam('controller');
	    $params['action'] = 'search';
		$url = $this->request->url_for($params);
		return $this->redirect()->toUrl($url);
	}
	
	public function searchAction()
	{
        // recover the sid
        $sid = $_SESSION[$this->id]['sid'];
        // kick the search off
        $this->query->sid = $sid;
        try
        {
		    $this->engine->search($this->query);
        }
        catch(\Exception $e)
        {
            // assume the session died, remove it & initialise a new one
            // FIXME NO, can be circular if not just a dead session
            // Need to generate an error message
            // Routing back to index for now
            $this->engine->clearPazpar2Client( $sid );
            $params = $this->query->getAllSearchParams();
		    $params['lang'] = $this->request->getParam('lang');
	        $params['controller'] = $this->request->getParam('controller');
	        //$params['action'] = 'startsession';
	        $params['action'] = 'index';
		    $url = $this->request->url_for($params);
		    return $this->redirect()->toUrl($url);
        }
		// if no exception,  redirect to results action
        $params = $this->query->getAllSearchParams();
		$params['lang'] = $this->request->getParam('lang');
	    $params['controller'] = $this->request->getParam('controller');
	    $params['action'] = 'results';
		$url = $this->request->url_for($params);
		return $this->redirect()->toUrl($url);
	}
	
    /**
     * This is called by searchAction once the search has been initiated and
     * again by javascript via ajaxstatusAction once the search has ended
     * Uses parent (SearchController) resultsAction
     */
     
	public function resultsAction()
	{
        //Debug::dump($this->query);
        $sid = $_SESSION[$this->id]['sid'];
        try
        {
		    $status = $this->engine->getSearchStatus($sid);
        }
        catch( \Exception $e )
        {
            // Exception probably a session timeout; go back to front page
            $fm = new FlashMessenger();
            $fm->addMessage('Session timeout: ' . $e->getMessage());
            $params = $this->query->getAllSearchParams();
		    $params['lang'] = $this->request->getParam('lang');
	        $params['controller'] = $this->request->getParam('controller');
	        $params['action'] = 'index';
		    $url = $this->request->url_for($params);
		    return $this->redirect()->toUrl($url);
        }
        // keep the session number for the AJAX code in the output HTML
	    $this->request->setSessionData('pz2session', $sid);
        // tell jquery whether to start the timer
	    $this->request->setSessionData('completed', (string) $status->isFinished());
        $this->request->setSessionData('targetnames', $this->query->getTargetNames()); 
        //Debug::dump($this->request); exit;
        // do the same with the query string
        $params = $this->query->getAllSearchParams(); 
        $pairs=array();
        foreach($params as $k => $v){
            if (is_array($v))
            {
                foreach($v as $e)
                {
                    $pairs[] = "$k=$e";
                }
            }
            else
            {
                $pairs[] = "$k=$v";
            }
        }
        $query_string = implode('&amp;', $pairs);
        // needed for the javascript redirect
        $this->request->setSessionData('querystring', $query_string); 
        $this->query->fillTargetInfo();

        if ($status->isFinished())
        {
            $result = parent::resultsAction();
        }
        else
        { 
            $result = array();
        }
        $result['status'] = $status->getTargetStatuses($this->query->getTargets());
        $result['externalLinks'] = $this->helper->addExternalLinks($this->config);
        return $result;
	}

    public function recordAction()
    {
        $id = $this->request->getParam('id'); 
        $sid = $_SESSION[$this->id]['sid'];
        $offset = $this->request->getParam('offset', null, true); 
        $targets = $this->query->fillTargetInfo();
        try
        {
            // get the record 
            $results = $this->engine->getRawRecord($sid, $id, $offset, $targets); 
        }
        catch( \Exception $e )
        {
            // Exception probably a session timeout; go back to front page
            $fm = new FlashMessenger();
            $fm->addMessage('Session timeout: ' . $e->getMessage());
            $params = $this->query->getAllSearchParams();
		    $params['lang'] = $this->request->getParam('lang');
	        $params['controller'] = $this->request->getParam('controller');
	        $params['action'] = 'index';
		    $url = $this->request->url_for($params);
		    return $this->redirect()->toUrl($url);
        }
        // set links 
        $this->helper->addRecordLinks($results); 
        $this->helper->addExternalRecordLinks($results, $this->config); 
        // add to response 
        //var_dump($results);
        $this->data["results"] = $results;
        return $this->data; 
    }

    /**
     *  Called by AJAX from results page to keep session alive 
     *  NB ZF2 not allowing underscores in Action names??
     */
	public function ajaxpingAction()
	{
		$sid = $this->request->getParam("session");
		$arr['live'] = $this->engine->ping($sid);
        $this->request->setParam("format", "json");
        $this->request->setParam("render", "false");
        $response = $this->getResponse(); 
        $response->setContent(json_encode($arr)); 
        // returned to View\Listener
        return $response;
	}

    /**
     * Terminate a search early when the user has lost patience
     */
	public function ajaxterminateAction()
	{
		$sid = $this->request->getParam("session");
        $this->engine->setFinished($sid);
        $this->request->setParam("format", "json");
        $this->request->setParam("render", "false");
        $response = $this->getResponse(); 
        $arr['sid'] = $sid;
        $response->setContent(json_encode($arr));
        return $response;
    }

    /**
     *  Called repeatedly by AJAX from results page until session is finished.
     *  Javascript then reloads results page, and resultsAction should
     *  populate it with search results.
     */
	public function ajaxstatusAction()
	{
		$sid = $this->request->getParam("session");
		$status = $this->engine->getSearchStatus($sid);
        $mystatus = array();
        $mystatus['status'] = $status->getTargetStatuses();
        unset($mystatus['status']['xml']);
        $mystatus['global'] = array();
        $mystatus['global']['finished'] = false;
        $mystatus['global']['progress'] = $status->getProgress();
        // set status to finished and add redirect address if needed
        if ($status->isFinished())
        {
            $params = $this->query->getAllSearchParams();
			$params['lang'] = $this->request->getParam('lang');
	        $params['controller'] = $this->request->getParam('controller');
	        $params['action'] = 'results';
            $mystatus['global']['finished'] = true;
		    $mystatus['global']['reload_url'] = $this->request->url_for($params);
        }
        $this->request->setParam("format", "json");
        $this->request->setParam("render", "false");
        $response = $this->getResponse(); 
        $response->setContent(json_encode($mystatus)); 
        //Debug::dump($response->getContent()); exit;
        // returned to View\Listener
        return $response;

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
			
            $sid = $_SESSION['pazpar2']['sid'];
            
			$record = $this->engine->getRawRecord($sid, $original_id)->getRecord(0)->getXerxesRecord();
			
			// save it
			
			$inserted_id = $datamap->addRecord( $username, $this->id, $original_id, $record );
			
			// record this in session
				
			$this->markSaved( $original_id, $inserted_id );
			
			$this->data["savedRecordID"] = $inserted_id;
		} 
		
		return $this->data;
	}	

}
