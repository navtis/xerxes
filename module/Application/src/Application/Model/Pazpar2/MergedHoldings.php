<?php

namespace Application\Model\Pazpar2;

/**
 * Result Holdings
 *
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class MergedHoldings
{
	public $holdings = array();
	
	/**
	 * Add holdings record to this group of holdings
	 * 
	 * @param Holdings $holdings
	 */
	
	public function addHoldings(Holdings $holdings)
	{
		array_push($this->holdings, $holdings);
	}
	
	/**
	 * Get all holdings
	 */
	
	public function getHoldings()
	{
		return $this->holdings;
	}	
	
	/**
	 * The number of holdings
	 */
	
	public function length()
	{
		return count($this->holdings);
	}
}
