<?php

namespace Application\Model\ULS;

use 
    Xerxes\Record\Format,
    Application\Model\Search;

/**
 * ULS Config
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Config extends \Application\Model\Pazpar2\Config
{
	protected $config_file = "config/uls";
    private static $instance;

    public static function getInstance()
    {
        if ( empty( self::$instance ) )
        {
            self::$instance = new Config();
            $object = self::$instance;
            $object->init();
        }
        return self::$instance;
    }

}
