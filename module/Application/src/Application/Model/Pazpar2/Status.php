<?php

namespace Application\Model\Pazpar2;

/**
 * Pazpar2 Search Status
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2012 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Status
{
	protected $stats = array(); // individual target statuses
	protected $timestamp = 0; // timestamp of status check
	protected $finished = false; // whether search is complete
    protected $result_set;
    protected $xml;

	public function __construct()
	{
		$this->timestamp = time();
	}
	
	public function addTargetStatus( $stat )
	{
		$this->stats[] = $stat;
	}
	
    public function getTargetStatus($tid)
	{
		return $this->stats[$tid];
	}
	
	public function getTargetStatuses()
	{
		return $this->stats;
	}

	public function SetResultSet( $rs )
	{
		$this->result_set = $rs;
	}
	
	public function getResultSet()
	{
		return $this->result_set;
	}
	
	
	public function setFinished($finished)
	{
		$this->finished = (bool) $finished;
	}
	
	public function isFinished()
	{
		return $this->finished;
	}
    /**
    * @param DomDocument $xml
    */
    public function setXml($xml)
    {
        $this->stats['xml'] = $xml;
    }    
    public function toXml()
    {
        return $this->stats['xml'];
    }    
}   
