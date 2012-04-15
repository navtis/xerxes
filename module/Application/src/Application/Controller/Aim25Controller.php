<?php

namespace Application\Controller;

use Application\Model\Aim25\HttpEngine,
    Zend\Mvc\MvcEvent,
    Zend\Debug;
/**
 * When a new pazpar2 search takes place, simultaneously search the
 * AIM25 (www.aim25.ac.uk) archive site to see if it has any possibly
 * related material. Return the counts, rather than the contents
 * This controller will either screen-scrape using the HttpEngine
 * or go via Z39.50 with the Pz2Engine. Unfortunately the counts returned
 * by Z39.50 do not match those returned by the web site which will be
 * linked to. 
 */
class Aim25Controller extends SearchController
{
	protected $id = "aim25";

    protected function getEngine()
    {
        return new HttpEngine();
    }

    public function indexAction()
    {
        return($this->data);
    }

    public function ajaxgethitsAction()
    {
        // the remote fetch should only occur once, when a new pz2
        // session is created for a new query. Otherwise, the existing
        // result should be returned.
        // FIXME this clunkiness with the $_SESSION data needs a rethink

        $sid = isset($_SESSION['pazpar2']) && isset($_SESSION['pazpar2']['sid'])?$_SESSION['pazpar2']['sid']:null;
        if ( is_null( $sid ) )
        {
            // if there's no session yet, just return nothing
            $hits = array();
            $hits['hits'] = 0;
        }
        else
        {
            $aid = isset($_SESSION['AIM25_'.$sid]) && isset($_SESSION['AIM25_'.$sid]['aid'])?$_SESSION['AIM25_'.$sid]['aid']:null;
            $hits = $this->engine->getHitCount($aid, $this->query);
            $engine_name = explode('\\', get_class($this->engine));
            $hits['engine'] = array_pop($engine_name);
            $_SESSION['AIM25_'.$sid]['aid'] = $hits['session'];
        }
        $this->request->setParam("format", "json");
        // FIXME would be much better to render with xsl
        // not js, but can't persuade it to work
        $this->request->setParam("render", "false");
        $response = $this->getResponse();
        $response->setContent(json_encode($hits)); 
        // returned to View\Listener
        return $response;
    }

}
