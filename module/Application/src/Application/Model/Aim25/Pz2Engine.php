<?php

namespace Application\Model\Aim25;

use Xerxes\Utility\Factory,
    Xerxes\Pazpar2,
	Zend\Http\Client;

/**
 * Engine which uses the AIM25 archives Z39.50 server
 * to return a count of items found by a search.
 * Too implement to implement a full search engine.
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Pz2Engine extends \Application\Model\Pazpar2\Engine
{
    /* getHitCount may be called multiple times: this
       is a lazy access to avoid keep calling the zclient
    */
    public function getHitCount($aim25sid, $query)
    {   
        $hits = array();

        if (! is_null( $aim25sid ) )
        {
            // should have hits stored away - no need to rerun
            $hits['hits'] = $this->cache()->get('hits_'.$aim25sid);
            $hits['url'] = $this->cache()->get('url_'.$aim25sid);
            $hits['session'] = $this->cache()->get('sid_'.$aim25sid);
        }
        else
        {
            $params = $query->getAllSearchParams();
            // the aim25 web search doesn't do Z39.50, so we need
            // to approximate as best we can
            if (($params['field'] == 'keyword')  
                || ($params['field'] == 'title')
                || ($params['field'] == 'author')
                )
            {
                $querystring = 'zany2?term1=' . urlencode($params['query']);
            }
            else if ($params['field'] == 'subject')
            {
                $querystring = 'zub2?term1=' . urlencode($params['query']);
            }
            else
            { 
            // we don't handle isbn etc
                $hits['hits'] = 0;
                return $hits;
            }
		    $url = $this->conf()->getConfig('AIM25_HTTPURL', false);
            $url .= $querystring;
            $hits['url'] = $url;

            // initialize without calling initializePazpar2Client()
            // as we don't want this client to overwrite the cached one
            $client = new Pazpar2($this->conf()->getConfig('url', true), false, null, $this->client);
            $aim25sid = $client->getSessionId();
            $hits['session'] = $aim25sid;

            // blocking (synchronous) call to pz2 search
		    $zurl = $this->conf()->getConfig('AIM25_ZURL', false);
            $res = $client->search( $query->toQuery(), array($zurl), null, null, true );
            $hits['hits'] = $res[$zurl]['records'];

            // cache so we don't need to rerun next time
            $this->cache()->set('hits_'.$aim25sid, $hits['hits']);
            $this->cache()->set('url_'.$aim25sid, $hits['url']);
            $this->cache()->set('sid_'.$aim25sid, $hits['session']);
        }
        return $hits;
    }   
}
