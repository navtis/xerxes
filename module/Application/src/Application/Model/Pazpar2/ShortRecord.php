<?php

namespace Application\Model\Pazpar2;

use Xerxes,
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


class ShortRecord extends Xerxes\Record
{
	protected $source = "pazpar2";
    protected $responsible; // munged list of editors etc

    // add extra fields to parent Record
    public function toXml()
    {
        $objXml = parent::toXml();
        # FIXME put local code like this somewhere local...
        Parser::addToXML($objXml, 'responsible', $this->responsible);
        if ($this->database_name == 'COPAC')
        {
            Parser::addToXML($objXml, 'source', 'COPAC: ' . $this->source);
        } 
        else
        {
            Parser::addToXML($objXml, 'source', $this->database_name);
        }
        return $objXml;
    }

	public function map()
	{
		
        $record = $this->document->documentElement->getElementsByTagName("hit")->item(0);

		$this->score = (string) $this->getElementValue($record, "relevance");
		//$this->database_name = $this->getElement($record, "location")->getAttribute("name");
		$this->holdings = $this->getElementValuesAttributePairs($record, "location", "name", "id");

        if ($this->database_name == 'COPAC' )
        { // COPAC are an aggregator themselves
		    $sources = $this->getElementValuesAttributes($record, "md-copaclocation", "code");
            $this->source = 'COPAC: ' . implode(",", $sources);
        }

            
		
		// description
		// FIXME make sure pazpar2 merges these by longest	
	    // $this->getElement( $record, "md-description" );
			
	    // record id
			
	    $this->record_id = urlencode((string)$this->getElementValue($record, "md-id"));

		// year
		// FIXME pazpar2 botches attempt to get data range in to date fields	
		$this->year = $this->getElementValue($record, "md-date");

	    // issn
			
		// FIXME no isbn, issn from pazpar2 at the moment?

		// authors 
		// FIXME preformatted by pazpar2 in md-title-responsibility	
		if (! is_null($this->getElementValue($record,"md-author") ) )
        {
		    $author = $this->getElementValue($record,"md-author");
            $author_object = new Xerxes\Record\Author($author, null, 'personal');
            $this->authors[] = $author_object;
        }
		if ( !is_null( $this->getElementValue($record,"md-title-reponsibility") ) )
        {
		    $this->responsible = $this->getElementValue($record,"md-title-responsibility");
	    }		
		// format
			
		$this->format->setFormat($this->getElementValue($record,"md-medium"));			
		
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
