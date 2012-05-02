<?php

/* Controller for the M25 Union List of Serials
   This Controller is specific to the M25 group and
   of no particular use to anyone else.
   It is a small extension to the pazpar2 controller, which
   limits targets to a fixed list, and maps specific journal title
   fields onto xerxes ones.
*/

namespace Application\Controller;

use Application\Model\ULS\Engine,
    Application\Model\DataMap\ULSTargets,
    Application\Model\DataMap\SavedRecords,
    Application\View\Helper\Pazpar2 as SearchHelper,
    Zend\Mvc\MvcEvent,
    Zend\Debug,
    Zend\Mvc\Controller\Plugin\FlashMessenger;

class ULSController extends Pazpar2Controller
{
	protected $id = "uls";

    protected function getEngine()
    {
        return new Engine();
    }

    /* Populate targets with the full set of ULS target data */
    public function indexAction()
    {
        $this->data['targets'] = $this->query->fillTargetInfo();
        //Debug::dump($this->data['targets']);
        return($this->data);
    }

}
