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

    public function __construct($results, $targets=null)
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
            $root = $doc->documentElement;
            $locs = $root->getElementsByTagName('location');
            $toDrop = array();
            foreach($locs as $loc )
            {
                $name = $loc->getAttribute('name');
                $name = strtoupper($name);
                if ( isset( $targets[$name] ) )
                {
                    // insert displayed target title in record
                    $node = $doc->createElement('location_title', $targets[$name]->title_short);
                    $loc->appendChild($node);
                }
                else
                {
                    // drop records not from this target list
                    $toDrop[] = $loc;
                }
            }
            foreach($toDrop as $loc)
            {
                // can't drop directly in original foreach or breaks loop
                $loc->parentNode->removeChild($loc);
            }
            $record = $doc->saveXML();
            $xerxes_record = new Record();
            $xerxes_record->loadXML( $record );
            $this->addRecord( $xerxes_record );
        }
    }

}
