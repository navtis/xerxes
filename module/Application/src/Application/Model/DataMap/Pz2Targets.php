<?php

namespace Application\Model\DataMap;

use Xerxes\Utility\DataMap,
	Application\Model\KnowledgeBase\Pz2Region,
	Application\Model\KnowledgeBase\Pz2Target,
    Zend\Debug;
/**
 * Target access mapper for pazpar2
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Pz2Targets extends DataMap
{
	protected $primary_language = "eng"; // primary language
	protected $searchable_fields; // fields that can be searched on for targets
	
	/**
	 * Constructor
	 * 
	 * @param string $connection	[optional] database connection info
	 * @param string $username		[optional] username to connect with
	 * @param string $password		[optional] password to connect with
	 */
	
	public function __construct($connection = null, $username = null, $password = null)
	{
		parent::__construct($connection, $username, $password);
		
		$languages = $this->registry->getConfig("languages");
		
		if ( $languages != "")
		{
			$this->primary_language = (string) $languages->language["code"];
		}

		// searchable fields
		
//		$this->searchable_fields = explode(",", $this->registry->getConfig("TARGET_SEARCHABLE_FIELDS", false, 
//			"title_display,title_short,description"));
	}

    /* 
    * THERE IS CURRENTLY NO CODE FOR DATABASE MANAGMENT
    * FIXME NEEDS TO BE ADDED
    */

    /*
    * UNLIKE METALIB-DERIVED 'DATABASES', THERE ARE NO USER_CREATABLE FEATURES
    */

    /*
    * DON'T NEED USER SEARCH FOR TARGETS
    */

	/**
	 * Get the regions from the knowledgebase
	 *
	 * @return array		array of Region objects
	 */
/*	
	public function getRegions()
	{
		$arrRegions = array ( );
		
		$strSQL = "SELECT * from xerxes_pz2_regions ORDER BY UPPER(name) ASC";
		
		$arrResults = $this->select( $strSQL );
		
		foreach ( $arrResults as $arrResult )
		{
			$objRegion = new Pz2Region( );
			$objRegion->load( $this->getRegion($arrResult['region_key']) );
			
			array_push( $arrRegions, $objRegion );
		}
		
		return $arrRegions;
	}
*/ 
    /* fetch the whole subtree for a given node. This would be very
    inneficient for a deep tree, but we expect it to be shallow */
	public function getRegionTree( $node=null )
	{
        if ( $node == null ) // only on first pass
        {
	        $node = new Pz2Region();
            $node->region_key = 'ALL';
		}    
        $newRegion = $this->getRegion( $node );
        
        if ( $newRegion == null ) return null;

        for( $i=0; $i < sizeof($newRegion->subregions); $i++ )
        {
            $subregion = $newRegion->subregions[$i];
            if ( sizeof( $subregion->targets ) == 0 )
            { // no targets, but may have further subregions
                $branch = $this->getRegionTree($subregion);
                //Debug::dump($branch);
                $newRegion->subregions[$i] = $branch; // may be null
            }
        }
        return $newRegion;
    }	
	
	/**
	 * Get an inlined set of subregions and targets for a region. 
	 *
	 * @param Region $objRegion     The root node for the tree to populate
	 * @return Region		        The root object, filled out with subregions and targets. 
	 */
	public function getRegion($objRegion)
	{
        $arrResults = array();

		$strSQL = "SELECT rmain.region_id as region_id, 
			rmain.name as region,
            rmain.region_key as region_key,
			rsub.region_id as subregion_id,
			rsub.name as subregion, 
			rsub.region_key as subregion_key, 
			xerxes_pz2_targets.*
			FROM xerxes_pz2_regions as rmain
			LEFT OUTER JOIN xerxes_pz2_regions as rsub ON rmain.region_id = rsub.parent_id
			LEFT OUTER JOIN xerxes_pz2_regions_targets ON xerxes_pz2_regions_targets.region_id = rsub.region_id
			LEFT OUTER JOIN xerxes_pz2_targets ON xerxes_pz2_regions_targets.target_id = xerxes_pz2_targets.target_id
			WHERE rmain.region_key = :value
			ORDER BY rmain.name, rsub.name, xerxes_pz2_targets.target_title_short";
		  
		$args = array (":value" => $objRegion->region_key );
		
		$arrResults = $this->select( $strSQL, $args );
		
        //Debug::dump($arrResults);
		if ( $arrResults == null )
        { 
            return null;
        }
		else
		{
			$objRegion->id = $arrResults[0]["region_id"];
			$objRegion->name = $arrResults[0]["region"];
			$objRegion->region_key = $arrResults[0]["region_key"];
			
			$objSubRegion = new Pz2Region( );
			$objSubRegion->id = $arrResults[0]["subregion_id"];
			$objSubRegion->name = $arrResults[0]["subregion"];
			$objSubRegion->region_key = $arrResults[0]["subregion_key"];
			
			$objTarget = new Pz2Target( );
			
			foreach ( $arrResults as $arrResult )
			{
                // if the node has no children, it is a dead end
                // we should return immediately
                if ( $arrResult["subregion_id"] == null )
                {
                    return $objRegion;
                }
				// if the current row's subregion name does not match the previous
				// one, then push the previous one onto region obj and make a new one
				if ( $arrResult["subregion_id"] != $objSubRegion->id )
				{
					// get the last target in this subregion first too.
					
					if ( $objTarget->target_id != null )
					{
						array_push( $objSubRegion->targets, $objTarget );
					}
					$objTarget = new Pz2Target( );

                    $objRegion->subregions[] = $objSubRegion;
					
					$objSubRegion = new Pz2Region();
					$objSubRegion->id = $arrResult["subregion_id"];
					$objSubRegion->name = $arrResult["subregion"];
					$objSubRegion->region_key = $arrResult["subregion_key"];
				}
				
				// if the previous row has a different target id, then we've come 
				// to a new target, otherwise these are values from the outer join

				if ( $arrResult["target_id"] != $objTarget->target_id )
				{
					// existing one that isn't empty? save it.
					
					if ( $objTarget->target_id != null )
					{
						array_push( $objSubRegion->targets, $objTarget );
					}
					
					$objTarget = new Pz2Target( );
					$objTarget->load( $arrResult ); // so target includes own region info
				}
				
			}
			
			// last ones
			
			if ( $objTarget->target_id != null )
			{
				array_push( $objSubRegion->targets, $objTarget );
			}
			array_push( $objRegion->subregions, $objSubRegion );

			return $objRegion;
		} 
    }

	/**
	 * Get a single target from the knowledgebase
	 *
	 * @param string $id				target id
	 * @return Target
	 */
	
	public function getTarget($id)
	{
		$arrResults = $this->getTargets( $id );
		
		if ( count( $arrResults ) > 0 )
		{
			return $arrResults[0];
		} 
		else
		{
			return null;
		}
	}
	
	/**
	 * Get the starting letters for target names
     * Using the key, as more distinctive than eg 'The University of...'
	 *
	 * @return array of letters
	 */	
	
	public function getDatabaseAlpha()
	{
		$strSQL = "SELECT DISTINCT alpha FROM " .
			"(SELECT SUBSTRING(UPPER(pz2_key),1,1) AS alpha FROM xerxes_pz2_targets) AS TEMP " .
			"ORDER BY alpha";
			
		$letters = array();
		$results = $this->select( $strSQL );
		
		foreach ( $results as $result )
		{
			array_push($letters, $result['alpha']);	
		}
		
		return $letters;
	}

	/**
	 * Get targets that start with a particular letter
	 *
	 * @param string $alpha letter to start with 
	 * @return array of Target objects
	 */	

	public function getTargetsStartingWith($alpha)
	{
		return $this->getTargets(null, null, $alpha);	
	}
	
	/**
	 * Get one or a set of targets from the knowledgebase
	 *
	 * @param mixed $id			[optional] null returns all targets, array returns a list of targets by id, 
	 * 							string id returns single id
	 * @return array			array of Target objects
	 */
	
	public function getTargets($key = null, $alpha = null)
	{
		$arrTargets = array ( );
		$arrResults = array ( );
		$arrParams = array ( );
		$where = false;
		$sql_server_clean = null;
		
		$strSQL = "SELECT * from xerxes_pz2_targets";

		// single database
		
		if ( $key != null && ! is_array( $key ) )
		{
			$strSQL .= " WHERE xerxes_pz2_targets.target_pz2_key = :key ";
			$arrParams[":key"] = $key;
			$where = true;
		} 		
		
		// targets specified by an array of ids
		
		elseif ( $key != null && is_array( $key ) )
		{
			$strSQL .= " WHERE ";
			$where = true;
			
			for ( $x = 0 ; $x < count( $key ) ; $x ++ )
			{
				if ( $x > 0 )
				{
					$strSQL .= " OR ";
				}
				
				$strSQL .= "xerxes_pz2_targets.target_pz2_key = :key$x ";
				$arrParams[":key$x"] = $key[$x];
			}
		} 
		
		// alpha query
		
		elseif ( $alpha != null )
		{
			$strSQL .= " WHERE UPPER(target_title_short) LIKE :alpha ";
			$arrParams[":alpha"] = "$alpha%";
			$where = true;
		}
		
		$strSQL .= " ORDER BY UPPER(target_title_display)";
		
		// echo $strSQL; print_r($arrParams); // exit;
		
		$arrResults = $this->select( $strSQL, $arrParams, $sql_server_clean );
		
		// transform to internal data objects
		
		if ( $arrResults != null )
		{
			foreach ( $arrResults as $arrResult )
			{
				$objTarget = new Pz2Target();
				$objTarget->load( $arrResult );
				//array_push($arrTargets, $objTarget);
				$arrTargets[$objTarget->pz2_key] = $objTarget;
			}
		}
		return $arrTargets;
	}
	
}
