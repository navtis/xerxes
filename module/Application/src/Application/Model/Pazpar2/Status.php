<?php

namespace Application\Model\Pazpar2;

use Zend\Debug;
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
    protected $progress = 0; // integer 0 - 10
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
	
    /**
     * Merge target display info with status results
     * @param array of Targets $db_targets
     */
	public function getTargetStatuses($db_targets=null)
	{
        if (is_null( $db_targets ))
        {
            return $this->stats;
        }
        // otherwise...
        $news = $this->stats;
        $s = $news['xml'];
        $targets = $s->getElementsByTagName('target');
        foreach($targets as $target)
        {
            $name = $target->getElementsByTagName('name')->item(0)->nodeValue;
            $name = strtoupper($name);
            # FIXME Get local rule out of here
            if ($name == 'COPAC')
            {
                $node = $s->createElement('title_short', 'COPAC');
            }
            else
            {
                $node = $s->createElement('title_short', $db_targets[$name]->title_short);
            }
            $target->appendChild($node);
        }
        $news['xml'] = $s;
        //echo($s->saveXML());
		return $news;
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
	
    public function setProgress($p)
	{
        // 0.0 <= $p <= 1.0
		$this->progress = intval( $p * 10 );
	}
    public function getProgress()
    {
        return $this->progress;
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
