<?php

namespace Application\Model\ULS;

use Application\Model\DataMap\ULSTargets,
    Xerxes\Utility\Request;

/**
 * Extends Pazpar2 Search Engine to use different 
 * configuration file and Target handling
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Engine extends \Application\Model\Pazpar2\Engine
{

	public function conf()
	{
        if ( ! $this->config instanceof Config )
        {
            $this->config = Config::getInstance();
        }
        return $this->config;
	}

   /**
    * Return a search query object
    * Replicates parent function to return correct subclass of Query
    * @param Request $request
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

