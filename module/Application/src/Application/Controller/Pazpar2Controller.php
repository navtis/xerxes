<?php

namespace Application\Controller;

use Application\Model\Pazpar2\Engine,
    Application\Model\DataMap\Pz2Targets,
    Application\View\Helper\Pazpar2 as SearchHelper,
    Zend\Mvc\MvcEvent,
    Zend\Debug,
    Zend\Mvc\Controller\Plugin\FlashMessenger,
    Application\Model\Pazpar2\Pz2Session;

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

	public function searchAction()
	{
        // initialise the search
		$session_id = $this->engine->search($this->query);
		// then  redirect to results action
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
        try
        {
		    $sid = (string) Pz2Session::getSavedId();
		    $status = $this->engine->getSearchStatus();
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
        return $result;
	}

    public function recordAction()
    {
        $id = $this->request->getParam('id'); 
        $offset = $this->request->getParam('offset', null, true); 
        $targets = $this->query->fillTargetInfo();
        try
        {
            // get the record 
            $results = $this->engine->getRawRecord($id, $offset, $targets); 
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
        // add to response 
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
}
