<?php

namespace Application\Model\Pazpar2;

use Application\Model\Knowledgebase\Target;

/**
 * pazpar2 Target result set
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

// FIXME this is quite token and just to satisfy the structure -
// pazpar2 has already merged the results
class TargetResultSet
{
	public $target;
	public $find_status;
	
	public function __construct(Target $target)
	{
		$this->target = $target;
	}
}
