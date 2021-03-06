<?php

namespace Application\Model\DataMap;

use Application\Model\Search\Refereed as RefereedValue,
	Xerxes\Utility\DataMap;

/**
 * Database access mapper for peer-reviewed data
 *
 * @author David Walker
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Refereed extends DataMap
{
	/**
	 * Delete all records for refereed journals
	 */
	
	public function flushRefereed()
	{
		$this->delete( "DELETE FROM xerxes_refereed" );
	}
	
	/**
	 * Add a refereed title
	 * 
	 * @param Refereed $objTitle peer reviewed journal object
	 */
	
	public function addRefereed(RefereedValue $title)
	{
		$title->issn = str_replace("-", "", $title->issn);
		$this->doSimpleInsert("xerxes_refereed", $title);
	}
	
	/**
	 * Get all refereed data
	 * 
	 * @return array of Refereed objects
	 */
	
	public function getAllRefereed()
	{
		$arrPeer = array();
		$arrResults = $this->select( "SELECT * FROM xerxes_refereed");
		
		foreach ( $arrResults as $arrResult )
		{
			$objPeer = new Refereed();
			$objPeer->load( $arrResult );
			
			array_push( $arrPeer, $objPeer );
		}		
		
		return $arrPeer;
	}
	
	/**
	 * Get a list of journals from the refereed table
	 *
	 * @param mixed $issn		[string or array] ISSN or multiple ISSNs
	 * @return array			array of Refereed objects
	 */
	
	public function getRefereed($issn)
	{
		$arrPeer = array ( );
		$arrResults = array ( );
		$strSQL = "SELECT * FROM xerxes_refereed WHERE ";
		
		if ( is_array( $issn ) )
		{
			if ( count( $issn ) == 0 )	throw new \Exception( "issn query with no values" );
			
			$x = 1;
			$arrParams = array ( );
			
			foreach ( $issn as $strIssn )
			{
				$strIssn = str_replace( "-", "", $strIssn );
				
				if ( $x == 1 )
				{
					$strSQL .= " issn = :issn$x ";
				} 
				else
				{
					$strSQL .= " OR issn = :issn$x ";
				}
				
				$arrParams["issn$x"] = $strIssn;
				
				$x ++;
			}
			
			$arrResults = $this->select( $strSQL, $arrParams );
		} 
		else
		{
			$issn = str_replace( "-", "", $issn );
			$strSQL .= " issn = :issn";
			$arrResults = $this->select( $strSQL, array (":issn" => $issn ) );
		}
		
		foreach ( $arrResults as $arrResult )
		{
			$objPeer = new RefereedValue();
			$objPeer->load( $arrResult );
			
			array_push( $arrPeer, $objPeer );
		}
		
		return $arrPeer;
	}
}
