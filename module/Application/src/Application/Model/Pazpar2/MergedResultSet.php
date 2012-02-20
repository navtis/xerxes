<?php

namespace Application\Model\Pazpar2;

use Zend\Debug,
    Application\Model\Search\ResultSet;

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
    public $num; // number of hits in this MergedResultSet
    protected $config; // local config

    public function __construct($results, $targets)
    {
    //var_dump($results);
    //Debug::dump($targets);
        $this->config = Config::getInstance();
        $this->start = $results['start'];
        $this->num = sizeof($results["hits"]); // should be = num
        $this->total = $results['merged']; 
        $final = array();
        foreach ( $results["hits"] as $record )
        {
        //Debug::dump($record);
            // merge the human-readable location name with the pz2 record
            $doc = new \DOMDocument();
            $doc->loadXML($record);
            $locs = $doc->getElementsByTagName('location');
            foreach($locs as $loc )
            {
                $name = $loc->getAttribute('name');
                $name = strtoupper($name);
                if ($name == 'COPAC')
                {
                    $node = $doc->createElement('location_title', 'COPAC');
                }   
                else
                {
                    $node = $doc->createElement('location_title', $targets[$name]->title_short);
                }
                $loc->appendChild($node);
            }
            $record = $doc->saveXML();
//Debug::dump($record);
            $xerxes_record = new Pz2Record();
            $xerxes_record->loadXML( $record );
            $this->addRecord( $xerxes_record );
        }
    }

}
