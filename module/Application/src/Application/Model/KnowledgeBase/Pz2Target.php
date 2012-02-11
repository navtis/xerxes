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
    public $_title_long;
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
		parent::load($arrResult);
	}
	
	/**
	 * Serialize
	 */
	
	public function __sleep()
	{
		// don't include config and simplexml elements
		
		return Parser::removeProperties(get_object_vars($this), array('config', 'xml'));
	}
	
	/**
	 * Get value of a field
	 *
	 * @param string $name field name
	 * @return string
	 */
	
	public function __get($name)
	{
		return (string) $this->simplexml()->$name;
	}
	
	/**
	 * Get values of all given fields
	 * 
	 * @param string $field field name
	 * @return array
	 */
	
	public function get($field)
	{
		$values = array();
		
		foreach ($this->simplexml()->$field as $value)
		{
			array_push($values, $value);
		}
		
		return $values;
	}
	
	/**
	 * Lazyload Config
	 */
	
	public function config()
	{
		if ( ! $this->config instanceof Config )
		{
			$this->config = Config::getInstance();
		}
	
		return $this->config;
	}
	
	/**
	 * Lazyload SimpleXmlElement
	 *
	 * @throws Exception
	 */
	public function simplexml()
	{
		if ( ! $this->xml instanceof \SimpleXMLElement )
		{
			if ( $this->target_id == "" )
			{
				throw new \Exception("Cannot access data, it has not been loaded");
			}
            $this->xml = $this->toXml(); //FIXME NOOOO, thats a DOMDocument
        }
		return $this->xml;
	}	
			
	/**
	 * Handling of note field escaping
	 * // FIXME porbably need to keep this for target descriptions, but format still undecided
	 * @param string $note_field
	 * @return string
	 */

	private function embedNoteField($note_field)
	{
		// description we handle special for escaping setting. Note that we
		// handle html escpaing here in controller for description, view
		// should use disable-output-escaping="yes" on value-of of description.

		$escape_behavior = $this->config()->getConfig("db_description_html", false, "escape"); // 'escape' ; 'allow' ; or 'strip'
		$note_field = str_replace('##', ' ', $note_field);
		
		if ( $escape_behavior == "strip" )
		{
			$allow_tag_list = $this->config()->getConfig("db_description_allow_tags", false, '');
			$arr_allow_tags = explode(',', $allow_tag_list);
			$param_allow_tags = '';
			
			foreach ( $arr_allow_tags as $tag )
			{
				$param_allow_tags .= "<$tag>";
			}
			$note_field = strip_tags($note_field, $param_allow_tags);
		}
		
		if ( $escape_behavior == "escape" )
		{
			$note_field = htmlspecialchars($note_field);
		}
		
		return $note_field;
	}
	
	/**
	 * Serialize to XML
	 *
	 * @return DOMDocument
	 */
	
	public function toXML()
	{
		// data is already in xml, we just use this opportunity to
		// enhance it with a few bits of data we don't already have
		if ( $this->target_id == "" )
		{
			throw new \Exception("Cannot access data, it has not been loaded");
		}
	
		$xml = new \DOMDocument();
		$xml->loadXML("<target />");
		$xml->documentElement->setAttribute("target_id", $this->target_id);
        foreach( $this->vars as $k => $v )
        {
            if ( preg_match( '/^target_/', $k ) )
            {
             $node = $xml->createElement(preg_replace('/^target_/','', $k), $v);
             $xml->documentElement->appendChild($node);
            }
        }
/*		$xml->documentElement->setAttribute("title_short", $this->title_short);
		$xml->documentElement->setAttribute("pz2_key", $this->pz2_key);
		$xml->documentElement->setAttribute("copac_key", $this->copac_key);
		$xml->documentElement->setAttribute("z3950_location", $this->z3950_location);
		$xml->documentElement->setAttribute("catalogue_url", $this->catalogue_url);
	
		$desc =	$xml->createElement('description', $this->description);
        $xml->documentElement->appendChild($desc);
*/	
		return $xml;
	}
}
