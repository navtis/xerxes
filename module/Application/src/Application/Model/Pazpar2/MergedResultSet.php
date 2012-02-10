<?php

namespace Application\Model\Pazpar2;

use Application\Model\Search\ResultSet;

/**
 * Pazpar2 Merged Result Set
 *
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class MergedResultSet extends ResultSet
{
	public $total; // number of merged records in full search results
    public $start; // start number of first result in this set
    public $num; // number of merged results in this MergedResultSet
    protected $config; // local config

    public function __construct($results)
    {
    //var_dump($results);
        $this->config = Config::getInstance();
        $this->start = $results['start'];
        $this->num = sizeof($results["hits"]); // should be = num
        $this->total = $results['total'];
        $final = array();
        foreach ( $results["hits"] as $record )
        {
            $xerxes_record = new ShortRecord();
            $xerxes_record->loadXML( $record );
            $this->addRecord( $xerxes_record );
        }
    }

}
