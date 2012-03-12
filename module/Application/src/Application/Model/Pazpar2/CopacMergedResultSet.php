<?php

namespace Application\Model\Pazpar2;

use Zend\Debug,
    Application\Model\Search\ResultSet;

/**
 * Pazpar2 Merged Result Set, with COPAC bib data if it exists
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class CopacMergedResultSet extends ResultSet
{
    // This is only ever used as a resultset of 1, a single (merged) displayed Record
    protected $config; // local config

    public function __construct($results, $targets)
    {
    // var_dump($results);
    //Debug::dump($targets);
        $this->config = Config::getInstance();
        $final = array();
        $copac_keys = array();
        $record = $results["hits"][0];
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
                $copac_keys[$targets[$name]->copac_key] = 1;
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
        if ( count($copac_keys) == 0 )
        {
            $xerxes_record = new Record();
        }
        else
        {
            //CopacRecord - but which loc to use?
            $xerxes_record = new Record();
        }
        $xerxes_record->loadXML( $record );
        //echo($record);
        $this->addRecord( $xerxes_record );
    }

}
