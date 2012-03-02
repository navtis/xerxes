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
     * and progress info
     * @param array of Targets $db_targets
     */
	public function getTargetStatuses($db_targets=null)
	{
        $news = $this->stats;
        $s = $news['xml'];

        $bt = $s->getElementsByTagName('bytarget')->item(0);
        $node = $s->createElement('progress', $this->progress);
        $bt->appendChild($node);
        $node = $s->createElement('finished', $this->finished);
        $bt->appendChild($node);

        if (is_null( $db_targets ))
        {
            $news['xml'] = $s;
            return $news;
        }
        // otherwise...
        $targets = $s->getElementsByTagName('target');
        foreach($targets as $target)
        {
            $name = $target->getElementsByTagName('name')->item(0)->nodeValue;
            $name = strtoupper($name);
            $node = $s->createElement('title_short', $db_targets[$name]->title_short);
            $target->appendChild($node);
        }
        $news['xml'] = $s;
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
		$this->progress = intval( $p * 100 );
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
