<?php

namespace Application\Model\KnowledgeBase;

use Application\Model\Authentication\User,
	Xerxes\Utility\DataValue,
	Xerxes\Utility\Parser,
    Zend\Debug,
	Xerxes\Utiltity\Restrict;

/**
 * target
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Pz2Target extends DataValue  
{
	public $target_id; 
    public $pz2_key;
    public $pz2_zurl;
    public $title_short;
    public $title_long;
    public $position; // display order
//    public $copac_key;
//    public $z3950_location;
//    public $catalogue_url;
//    public $description;
    // FIXME need to add all the z39.50 config for the target
	private $config; // target config
    private $vars; // raw vars from sql
	private $xml; // simplexml
    public $data; // string version of $xml
	
	/**
	 * Load data from target results array
	 *
	 * @param array $arrResult
	 * @param User $user
	 */
	
	public function load($arrResult)
	{
        $this->vars = $arrResult; // keep for use later
        $this->pz2_key = $this->vars['target_pz2_key'];
        $this->pz2_zurl = $this->vars['target_z3950_location'];
        $this->title_short = $this->vars['target_title_short'];
        $this->title_long = $this->vars['target_title_display'];
        $this->enabled = $this->vars['target_enabled'];
        // SEARCH25 specific variable
        $this->copac_key = $this->vars['target_copac_key'];
		parent::load($arrResult);
	}
	
    public function setPosition($i)
    {
        $this->position = $i;
    }

	/**
	 * Serialize to XML
	 *
	 * @return DOMDocument
	 */
	
	public function toXML()
	{
		// data is already in xml, we just use this opportunity to
		// enhance it with the target data
		if ( $this->target_id == "" )
		{
			throw new \Exception("Cannot access data, it has not been loaded");
		}
	
		$xml = new \DOMDocument();
		$xml->loadXML("<target />");
		$xml->documentElement->setAttribute("target_id", $this->target_id);
		$xml->documentElement->setAttribute("position", $this->position);
        if (isset( $this->textValue ) )
        {
            // check checkbox
		    $xml->documentElement->setAttribute("textValue", $this->textValue);
        }
        foreach( $this->vars as $k => $v )
        {
            if ( preg_match( '/^target_/', $k ) )
            {
             $node = $xml->createElement(preg_replace('/^target_/','', $k), $v);
             $xml->documentElement->appendChild($node);
            }
        }
		return $xml;
	}
}
