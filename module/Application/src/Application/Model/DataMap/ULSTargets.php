<?php

namespace Application\Model\DataMap;

use Xerxes\Utility\DataMap,
	Application\Model\KnowledgeBase\Pz2Region,
	Application\Model\KnowledgeBase\Pz2Target,
    Zend\Debug;
/**
 * Target access mapper for Union list of serials using pazpar2
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class ULSTargets extends \Application\Model\DataMap\Pz2Targets
{
    public $targetnames;

    public function __construct($targetnames = null, $connection = null, $username = null, $password = null)
    {
        parent::__construct($connection, $username, $password);

        $this->targetnames = $this->getULSList();
    }

    public function getULSList()
    {
	    $node = new Pz2Region();
        $node->region_key = 'ULS_PARENT';
        $v = 1;
        $this->targetnames = array();
        $rt = $this->getRegion( $node, $v );
        $list = array();
        foreach($rt->subregions[0]->targets as $target)
        {
            $list[] = $target->pz2_key;
        }
        return $list;
    }
}
