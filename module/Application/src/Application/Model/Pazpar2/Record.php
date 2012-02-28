<?php

namespace Application\Model\Pazpar2;

use Xerxes,
    Zend\Debug,
	Xerxes\Utility\Parser,
	Xerxes\Record\Chapter,
	Xerxes\Record\Subject,
    Application\Model\Search\Item,
    Application\Model\Search\Holding;

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

/* FIXME inherits huge list of fields from parent; make sure these are
populated as far as possible GS */
class Record extends Xerxes\Record
{
	protected $source = "pazpar2";
    protected $responsible; // munged list of editors etc
    protected $locations; // array of unique target names and titles
    protected $mergedHoldings; // container for all Holdings for record

    // add extra fields to parent Record
    public function toXml()
    {
        $objXml = parent::toXml();

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
        // extent is used in Bibliographic - what for?
		$this->extent = $this->getElementValue($record,"md-physical-extent");
        
        // Xerxes doesn't seem to use this info by default, so this is a new field
        $physical = array();
        if (! is_null( $this->getElementValue($record,"md-physical-format") ) )
        {
            $physical[] = $this->getElementValue($record,"md-physical-format");
        }
        if (! is_null( $this->getElementValue($record,"md-physical-extent") ) )
        {
            $physical[] = $this->getElementValue($record,"md-physical-extent");
        }
        if (! is_null( $this->getElementValue($record,"md-physical-dimensions") ) )
        {
            $physical[] = $this->getElementValue($record,"md-physical-dimensions");
            foreach($physical as &$p)
                $p = trim($p, '.;,');
            $this->physical = implode("; ", $physical);
        }

        // fetch the unique target library names and keys for this record
        // for use on results page
		$locations = $record->getElementsByTagName('location');
        foreach($locations as $location)
        {
            $this->locations[$location->getAttribute('name')] = $this->getElementValue($location, "location_title");
        }
        // and now get the holdings information
        // for use on record page
        
        $this->populateHoldings($locations);

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
	    $this->description = implode(' ', $this->getElementValues( $record, "md-xerxes-note") );
	    $this->snippet = $this->getElementValue( $record, "md-snippet" );
	    $this->abstract = $this->getElementValue( $record, "md-abstract" );
			
	    // record id
			
        // FIXME What is the md-id value?
	    //$this->record_id = urlencode((string)$this->getElementValue($record, "md-id"));
	    $this->record_id = urlencode((string)$this->getElementValue($record, "recid"));

		// year
		$this->year = $this->getElementValue($record, "md-date");
		
        $this->edition = $this->getElementValue($record, "md-edition");

		// authors 
		if (! is_null($this->getElementValue($record,"md-author") ) )
        {
		    $author = $this->getElementValue($record,"md-author");
            $this->authors[] = new Xerxes\Record\Author($author, null, 'personal');
        }
		if ( !is_null( $this->getElementValue($record,"md-title-responsibility") ) )
        {
		    $responsible = trim( $this->getElementValue($record,"md-title-responsibility") );
            // remove fully enclosing brackets
            $responsible = trim( preg_replace( '/^\[([^\]]*)\]$/', '$1', $responsible ) );
            
            // try to extract people and their roles
            $role = ''; $persons='';
            if ( preg_match('/^\[(.*)\](.*)$/', $responsible, $matches) )
            {
                $role = $matches[1];
                $persons = $matches[2];
            } 
            else if ( preg_match('/^(.*) by (.*)$/', $responsible, $matches) )
            {
                $role = $matches[1];
                $persons = $matches[2];
            } 
            else if ( preg_match('/^ed. (.*)$/i', $responsible, $matches) )
            {
                $role = 'Editor';
                $persons = $matches[1];
            } 
            else if ( preg_match('/^editors?(.*)$/i', $responsible, $matches) )
            {
                $role = 'Editor';
                $persons = $matches[1];
            }
            if (preg_match('/edit/i', $role) )
            {
                $role = 'Editor';
            }
            //echo("<p>role: $role people: $persons</p>");
            // if we don't have the people in the authors, try to add them
            // FIXME should have a 'match' function in Author
            $people = explode(',', $persons); // may be a list
            $found = false;
            if ( count($this->authors) > 0 )
            {
                foreach ($people as $person)
                {
                    $title_parts = preg_split('/\W/', $person);
                    foreach($this->authors as $author)
                    { 
                        // let's hope its not John and Jane Smith
                        if ( in_array($author->last_name, $title_parts) ) 
                        { 
                            $found = true; 
                            break;
                        } 
                    } 
                }
            }
            if (! $found )
            {
                $this->responsible = $responsible;
                /* too dangerous adding to primary author 
                if ( count($this->authors) > 0 ){
                    $additional = true;
                }
                else
                {
                    $additional = false;
                }
                foreach ($people as $person)
                {
                    $this->authors[] = new Xerxes\Record\Author($person, null, 'personal', $additional);
                  
                }
                */
            }

        }
		if (! is_null($this->getElementValue($record,"md-meeting-name") ) )
        {
		    $author = $this->getElementValue($record,"md-meeting-name");
            $author_object = new Xerxes\Record\Author($author, null, 'conference');
            $this->authors[] = $author_object;
        }
		if (! is_null($this->getElementValue($record,"md-corporate-name") ) )
        {
		    $author = $this->getElementValue($record,"md-corporate-name");
            $author_object = new Xerxes\Record\Author($author, null, 'corporate');
            $this->authors[] = $author_object;
        }

        // publication information
        $this->place = $this->getElementValue($record, "md-publication-place");
		$this->publisher = $this->getElementValue($record, "md-publication-name");
        if ( is_null($this->year) )
        {
		    $this->year = $this->getElementValue($record, "md-publication-date");
        }
        
        // Table of Contents, if any
		if (! is_null($this->getElementValue($record,"md-toc") ) )
        {   
            $this->parseTOC($this->getElementValue($record,"md-toc"));
        }

        //subjects
		$subjects = $this->getElementValues($record, "md-subject-long");
        // remove duplicates
        $subjects = array_unique($subjects); 
        // sort into ascending length
        usort($subjects, function($a, $b) {
            return strlen($a) - strlen($b);
        });

        /* this version keeps the original strings */
        foreach( $subjects as $subject)
        {
            $subject_object = new Subject();
            $subject_object->display = (string) $subject;
            $subject_object->value = (string) $subject;

            array_push($this->subjects, $subject_object);
        }

        /* this alternative version breaks into separate terms: not better? 
        // Split all subjects into component parts and order by frequency
        $subj_array = array();
        foreach( $subjects as $subject)
        {
            $bits = explode(',', $subject);
            foreach($bits as $bit)
            {
                $subj_array[] = trim($bit);
            }
        }
        $subj_count = array_count_values($subj_array);
        arsort($subj_count);
        foreach( $subj_count as $subject => $count)
        {
            $subject_object = new Subject();
            $subject_object->display = (string) $subject;
            $subject_object->value = (string) $subject;

            array_push($this->subjects, $subject_object);
        }
        */
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

    /**
     * Populate mergedHoldings with holding/circulation information returned
     * from Z-Servers
     * @param elementList $locations
     */
    protected function populateHoldings($locations)
    {
        $this->mergedHoldings = new MergedHoldings();

        $domxpath = new \DOMXPath($this->document);
        
        foreach($this->locations as $loc_name => $loc_title)
        {
            $hs = new Holdings();
            $hs->setTargetName($loc_name);
            $hs->setTargetTitle($loc_title);
           
            $recs = $domxpath->query("//location[@name='$loc_name']");
            foreach( $recs as $rec ) 
            {
                //if an electronic url, storeit
                $els = $rec->getElementsByTagname("md-electronic-url");
                foreach($els as $el)
                {
                    $h = new Holding();
                    $h->setProperty( '856', $el->nodeValue );
                    $hs->addHolding($h);
                }

                $els = $rec->getElementsByTagname("md-opacholding");
                foreach($els as $el)
                {
                    // a bare holding, without circulation info
                    $i = new Item();
                    $i->setProperty("callnumber", $el->getAttribute('callnumber'));
                    $i->setProperty("location", $el->getAttribute('locallocation'));
                    $hs->addItem($i);
                }                        
                
                $els = $rec->getElementsByTagname("md-opacitem");
                foreach($els as $el)
                {
                    // circulation data
                    $i = new Item();
                    $i->setProperty("bib_id", $el->getAttribute('itemid'));
                    $i->setProperty("availability", $el->getAttribute('available'));
                    $i->setProperty("status", $el->getAttribute('duration'));
                    $i->setProperty("location", $el->getAttribute('locallocation'));
                    $i->setProperty("reserve", $el->getAttribute('onhold'));
                    $i->setProperty("duedate", $el->getAttribute('duedate'));
                    $i->setProperty("callnumber", $el->getAttribute('callnumber'));
                    $hs->addItem($i);
                }
                if ($hs->hasMembers())
                {  // FIXME may be empty if user selected only one location - should weed out
                   // empties earlier, but for now, kludge
                    $this->mergedHoldings->addHoldings($hs);
                }

            }    
        }
    }

    public function getMergedHoldings()
    {
        return $this->mergedHoldings;
    }

    protected function parseTOC($table_of_contents)
    {

        if ( $table_of_contents != "" ) 
        { 
            $chapter_titles_array = explode("--", $table_of_contents); 
            foreach ( $chapter_titles_array as $chapter ) 
            { 
                $chapter_obj = new Chapter($chapter); 
                if ( strpos($chapter, "/") !== false ) 
                { 
                    $chapter_parts = explode("/", $chapter); 
                    $chapter_obj->title = $chapter_parts[0]; 
                    $chapter_obj->author = $chapter_parts[1]; 
                } 
                else 
                { 
                    $chapter_obj->statement = $chapter; 
                } 
                $this->toc[] = $chapter_obj;
            }
        }
        //Debug::dump($this->toc);
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
		
		return array_unique($values);
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
