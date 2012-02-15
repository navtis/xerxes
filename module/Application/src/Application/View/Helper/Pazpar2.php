<?php

namespace Application\View\Helper;

class Pazpar2 extends Search
{

    public function facetParams()
    {
        $params = $this->currentParams();
        $params['action'] = 'search';
    }

}

?>
