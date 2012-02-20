<?php

namespace Application\Model\Pazpar2;

use Xerxes,
    Zend\Debug,
	Xerxes\Utility\Parser;

/**
 * Pazpar2 Record
 * 
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */


class Pz2Record extends Xerxes\Record
{
	protected $source = "pazpar2";
    protected $responsible; // munged list of editors etc

    // add extra fields to parent Record
    public function toXml()
    {
        $objXml = parent::toXml();
        Parser::addToXML($objXml, 'responsible', $this->responsible);
//        echo($objXml->saveXML());
/*
        # FIXME put local code like this somewhere local...
        if ($this->database_name == 'COPAC')
        {
            Parser::addToXML($objXml, 'source', 'COPAC: ' . $this->source);
        } 
        else
        {
            Parser::addToXML($objXml, 'source', $this->database_name);
        }

*/
        return $objXml;
    }
    /** Map the xml returned by Pazpar2 onto the standard set of 
     * Record elements, which toXML() will then expand into Xerxes
     * xml format 
     */
	public function map()
	{
		
        if ( ! is_null( $this->document->documentElement->getElementsByTagName("hit")->item(0) ) )
        {
            // we've come from 'search'
            $record = $this->document->documentElement->getElementsByTagName("hit")->item(0);
        }
        else
        { 
            // this is a single 'record' already
            $record = $this->document->documentElement;
        }
//var_dump($this->document->saveXML());
		$this->score = (string) $this->getElementValue($record, "relevance");
       
		$this->title = (string) $this->getElementValue($record, "md-title");
		$this->sub_title = (string) $this->getElementValue($record, "md-title-remainder");
		$this->series_title = (string) $this->getElementValue($record, "md-series-title");

        $this->isbns = array_unique($this->getElementValues($record, "md-isbn") );
		$this->language = (string) $this->getElementValue($record, "md-language");

		// format			
		$risformat = $this->getElementValue($record,"md-medium");
		$this->format->setFormat($risformat);
        $this->format->setPublicFormat($this->format->getConstNameForValue($risformat));

		$this->extent = $this->getElementValue($record,"md-physical-extent");		//echo("Extent: ".$this->extent);	
		//$this->database_name = $this->getElement($record, "location")->getAttribute("name");
		//$this->holdings = $this->getElementValuesAttributePairs($record, "location", "name", "id");
		$this->holdings = array_unique( $this->getElementValues($record, "location_title") );

/* this was to provide unique identifiers (offset values) for each
copy of a book, to be used by pz2_record. Not needed? */
/*
		$this->holdings = array();
        $hs = array_unique($this->getElementValues($record, "location_title") );
        foreach($hs as $h)
        {
            $this->holdings[$h] = array();
        }
        $hs = $this->getElementValues($record, "location_title");
        $i = 0;
        foreach($hs as $h) // populate the offset values for the target
        {
            $this->holdings[$h][] = $i++;
        }
        Debug::dump($this->holdings);
*/
/*
        if ($this->database_name == 'COPAC' )
        { // COPAC are an aggregator themselves
		    $sources = $this->getElementValuesAttributes($record, "md-copaclocation", "code");
            $this->source = 'COPAC: ' . implode(",", $sources);
        }
*/
            
		
		// description
	    $this->description = $this->getElementValue( $record, "md-description" );
        //echo("ABSTRACT: ".$this->abstract->saveXML());
	    $this->snippet = $this->getElementValue( $record, "md-snippet" );
			
	    // record id
			
        // FIXME What is the md-id value?
	    //$this->record_id = urlencode((string)$this->getElementValue($record, "md-id"));
	    $this->record_id = urlencode((string)$this->getElementValue($record, "recid"));

		// year
		$this->year = $this->getElementValue($record, "md-date");
		
        $this->edition = $this->getElementValue($record, "md-edition");

		// authors 
		// preformatted by pazpar2 in md-title-responsibility	
		if ( !is_null( $this->getElementValue($record,"md-title-responsibility") ) )
        {
		    $this->responsibility = $this->getElementValue($record,"md-title-responsibility");
        }
		if (! is_null($this->getElementValue($record,"md-author") ) )
        {
		    $author = $this->getElementValue($record,"md-author");
            $author_object = new Xerxes\Record\Author($author, null, 'personal');
            $this->authors[] = $author_object;
        }

        // publication information
        $this->place = $this->getElementValue($record, "md-publication-place");
		$this->publisher = $this->getElementValue($record, "md-publication-name");
		$this->year = $this->getElementValue($record, "md-publication-date");



		// article data
        //FIXME 
        $addata = null;	
		if ( $addata != null)
		{
			$this->journal_title = $this->start_page = $this->getElementValue($addata,"jtitle");
			$this->volume = $this->getElementValue($addata,"volume");
			$this->issue = $this->getElementValue($addata,"issue");
			$this->start_page = $this->getElementValue($addata,"spage");
			$this->end_page = $this->getElementValue($addata,"epage");
			
			// abstract 
			
			$abstract = $this->getElementValue($addata,"abstract");
			
			if ( $this->abstract == "" )
			{
				$this->abstract = strip_tags($abstract);
			}

	    }	
		// title
		
		{
			$this->title = $this->getElementValue($record,"md-title");
		}
//echo("<br />");
//echo($this->document->saveXML());
//echo("<br />");
//var_dump($this->holdings);
//echo("<br />");
//echo("<br />");
//exit;
	}
	
	protected function getElement($node, $name)
	{
		$elements = $node->getElementsByTagName($name);
		
		if ( count($elements) > 0 )
		{
			return $elements->item(0);
		}
		else
		{
			return null;
		}
	}
	
	protected function getElementValue($node, $name)
	{
		$element = $this->getElement($node, $name);
		
		if ( $element != null )
		{
			return $element->nodeValue;
		}
		else
		{
			return null;
		}
	}
	
	protected function getElementValues($node, $name)
	{
		$values = array();
		
		$elements = $node->getElementsByTagName($name);
		
		foreach ( $elements as $node )
		{
			array_push($values, $node->nodeValue);
		}
		
		return $values;
	}		
	protected function getElementValuesAttributes($node, $name, $attrname)
	{
		$values = array();
		
		$elements = $node->getElementsByTagName($name);
		
		foreach ( $elements as $node )
		{
			array_push($values, $node->getAttribute($attrname));
		}
		
		return $values;
    }
	protected function getElementValuesAttributePairs($node, $name, $keyname, $valname)
	{
		$values = array();
		
		$elements = $node->getElementsByTagName($name);
		
		foreach ( $elements as $node )
		{
			$values[$node->getAttribute($keyname)] = $node->getAttribute($valname);
		}
		return $values;
    }
}

?>
