<?php

namespace Application\Controller;

use Application\Model\Pazpar2\Engine,
    Application\Model\DataMap\Pz2Targets,
    Zend\Debug,
    Application\Model\Pazpar2\Pz2Session;

class Pazpar2Controller extends SearchController
{
	protected $id = "pazpar2";
	
	protected function getEngine()
	{
		return new Engine();
	}

    public function indexAction()
    {
        $this->data['regions'] = $this->engine->getRegions();
        //echo ($this->data['regions']->toXml()->saveXML() ); exit;
       // Debug::dump($regions ); exit;
        return($this->data);
    }

    public function libraryAction()
    {
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
     * This is called once the search has been initiated and
     * again by javascript via ajaxstatusAction once the search has ended
     * Uses parent (SearchController) resultsAction
     */
     
	public function resultsAction()
	{
        $result = parent::resultsAction();
		$sid = (string) Pz2Session::getSavedId();
		$status = $this->engine->getSearchStatus();
        // keep the session number for the AJAX code in the output HTML
	    $this->request->setSessionData('pz2session', $sid);
        // tell jquery whether to start the timer
	    $this->request->setSessionData('completed', (string) $status->isFinished());
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
        $result['status'] = $status->getTargetStatuses($this->query->getTargets());
        //Debug::dump($result);// exit;
        //Debug::dump($this->request); exit;
        return $result;
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
