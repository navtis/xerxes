<?php

namespace Application\Model\ULS;

use Application\Model\DataMap\ULSTargets,
	Application\Model\Search,
    Zend\Debug,
	Xerxes\Utility\Request;

/**
 * Search Query
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Query extends \Application\Model\Pazpar2\Query
{

	public function fillTargetInfo()
	{
		// populate the target information from KB
        // for ULS we always use the full set
		$this->datamap = new ULSTargets(); 
		
	    $this->targets = $this->datamap->getTargets($this->datamap->targetnames);

        return $this->targets;
	}
}
