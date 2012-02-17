<?php

namespace Application\View\Helper;

use Xerxes\Record;

class Pazpar2 extends Search
{

    public function facetParams()
    {
        $params = $this->currentParams();
        $params['action'] = 'search';

        return $params;
    }

    /** 
    * URL for the full record display, including targets 
    * 
    * @param $result Record object 
    * @return string url 
    */ 
    public function linkFullRecord( Record $result ) 
    { 
        $arrParams = array( 
            'controller' => $this->request->getParam('controller'), 
            "action" => "record", 
            "id" => $result->getRecordID(), 
            'target' => $this->request->getParam('target', null, true) 
        ); 
        return $this->request->url_for($arrParams); 
    } 

}

?>
