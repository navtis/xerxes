<?php

namespace Application\Model\Pazpar2;

use Application\Model\DataMap\Pz2Targets,
    Application\Model\Search,
    Zend\Debug,
	Xerxes\Pazpar2,
	Xerxes\Utility\Factory,
	Xerxes\Utility\Cache,
	Xerxes\Utility\Request;

/**
 * Pazpar2 Search Engine
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */

class Engine extends Search\Engine
{
	protected static $client; // pazpar2 client/driver
	protected $cache;

	/**
	 * Return the total number of hits for the search
	 * Required by abstract parent
	 * @return int
	 */
	
	public function getHits( Search\Query $search ) {}	


	/**
	 * Search and return results
     * Called from SearchController::resultsAction
     * Required by abstract parent
	 *
	 * @param Query $search		search object
	 * @param int $start							[optional] starting record number
	 * @param int $max								[optional] max records
	 * @param string $sort							[optional] sort order
	 *
	 * @return Results
	 */
	
	public function searchRetrieve( Search\Query $search, $start = 0, $max = 100, $sort = "" )
    {
        // recover sid from Zend session
        $sid = Pz2Session::getSavedId();
        // and use it to recover the Session from cache
        $session = unserialize( $this->cache()->get($sid) );
        
        $targets  = $search->fillTargetInfo();
        $start = $start - 1; // allow for pz2 starting from 0
        $max = $max - 1;
        return $session->merge($start, $max, $sort, $targets);
    }

	/**
	 * Return an individual record
	 * Just wraps session getRecord
     *
	 * @param string	record identifier
	 * @return Resultset
	 */
    // FIXME no error trapping if either sid or cached session has gone away
	public function getRawRecord( $id, $offset=array(), $targets=null )
    {
        // recover sid from Zend session
        $sid = Pz2Session::getSavedId();
        $session = unserialize( $this->cache()->get($sid) );
        return $session->getRecord( $id, $offset, $targets );
    }

	/**
	 * Return an individual record - unused, we use getRawRecord()
     * to avoid the constraint on the number of parameters
	 * Required by abstract parent
     *
	 * @param string	record identifier
	 * @return Resultset
	 */

	public function getRecord( $id ){}

	/**
	 * Get record to save
	 * Required by abstract parent
     *
	 * @param string	record identifier
	 * @return int		internal saved id
	 */
	
	 public function getRecordForSave( $id ) {}
	
	/**
	 * Return the search engine config
	 * Required by abstract parent
     *
	 * @return Config
	 */
	
	public function getConfig()
	{
		return Config::getInstance();
	}

    /**
     * Return a search query object
     * Replicates parent function to return correct subclass of Query
     * @param Request $request
     * @return Query
     */
     public function getQuery(Request $request )
     {
        if ( $this->query instanceof Query )
        {
            return $this->query;
        }
        else
        {
            return new Query($request, $this->getConfig());
        }
     }

    /* class-specific functions */


    public function getRegions()
    {
        $targets = new Pz2Targets();
        return $targets->getRegionTree();
    }

   /**
    * Pazpar2 Client
    * Kept by the engine, used by Pz2Sessions
    */
    public static function getPazpar2Client()
    {

        if ( ! self::$client instanceof Pazpar2 )
        {
            $config = Config::getInstance();
            self::$client = new Pazpar2($config->getConfig('url', true), false, null, Factory::getHttpClient());
        }
        return self::$client;
    }


    /* called on serialization */
	public function __sleep()
	{
        // nothing to do for now
	}
	
    /* called on unserialization */
	public function __wakeup()
	{
		$this->__construct(); // parent constructor
	}
	
	
    /**
     * Return the sid for a pz2 search session it has cached
     * Overrides parent
     *
     * @return Query
     */
    public function search(Query $query, $start=0, $max=100) 
    {
        $pz2session = new Pz2Session();
        
        // after this, $query is stored in the pz2session
        $pz2session->initiateSearch($query);
       
        $sid = $pz2session->getId();

        // cache the session object for later retrieval
        $this->cache()->set($sid, serialize($pz2session));

        return $sid;
    }

    public function getSearchStatus()
    {
        // recover sid from Zend session
        $sid = Pz2Session::getSavedId();

        $session = unserialize( $this->cache()->get($sid) );

        $status = $session->getSearchStatus($sid);

		return $status;
	}

    /* called from pingAction */
    /* return boolean live or not */
    public function ping($sid)
    {
        $sid = Pz2Session::getSavedId();
        // and use it to recover the Session from cache
        $session = unserialize( $this->cache()->get($sid) );
        return $session->client()->pz2_ping($sid);
	}
	
	
	
    /**
    * Lazyload Cache
    */
    protected function cache()
    {
        if ( ! $this->cache instanceof Cache )
        {
            $this->cache = new Cache();
        }
        return $this->cache;
    }

}

