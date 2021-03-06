<?php

namespace Application\View;

use Application\View\Helper\Navigation,
	ArrayAccess,
	Xerxes\Utility\Request,
	Xerxes\Utility\Registry,
	Xerxes\Utility\ViewRenderer,
	Zend\EventManager\EventCollection,
	Zend\EventManager\ListenerAggregate,
	Zend\Stdlib\ResponseDescription as Response,
	Zend\View\Model,
	Zend\View\View,
	Zend\View\ViewEvent;

class Strategy implements ListenerAggregate
{
	protected $listeners = array(); // listeners
	protected $renderer; // xerxes view renderer
	protected $view; // view
	protected $enhanced = false;
	
	/**
	 * Set view
	 *
	 * @param  View $view
	 */
	
	public function __construct(ViewRenderer $view_renderer)
	{
		$this->view = new View();
		$this->renderer = $view_renderer;
		return $this;
	}
	
	/**
	 * Retrieve the composed renderer
	 *
	 * @return ViewRenderer
	 */
	
	public function getRenderer()
	{
		return $this->renderer;
	}
	
	/**
	 * Attach the aggregate to the specified event manager
	 *
	 * @param  EventCollection $events
	 * @param  int $priority
	 * @return void
	 */	
	
	public function attach(EventCollection $events, $priority = 1)
	{
		$this->listeners[] = $events->attach('renderer', array($this, 'selectRenderer'), $priority);
		$this->listeners[] = $events->attach('response', array($this, 'injectResponse'), $priority);
	}
	
	/**
	 * Detach aggregate listeners from the specified event manager
	 *
	 * @param  EventCollection $events
	 * @return void
	 */	
	
	public function detach(EventCollection $events)
	{
		foreach ( $this->listeners as $index => $listener ) 
		{
			if ( $events->detach($listener) ) 
			{
				unset($this->listeners[$index]);
			}
		}
	}
	
	/**
	 * Select the ViewRenderer
	 * 
	 * @param  ViewEvent $e
	 * @return ViewRenderer
	 */
	
	public function selectRenderer(ViewEvent $e)
	{
		if ( $this->enhanced == false )
		{
			$request = $e->getRequest();
			$model = $e->getModel();
			
			// this happens if the route is not matched properly
			
			if ( ! $request instanceof Request )
			{
				$request = new Request();
				$e->setRequest($request);
			}
			
			// add base elements
			
			$model->setVariable("base_url", $request->getServerUrl() . $request->getBaseUrl());
			$model->setVariable("request", $request);
			$model->setVariable("config", Registry::getInstance());
			
			// add navigation
			
			$nav = new Navigation($e);
			$model->setVariable("navbar", $nav->getNavbar());
			
			// show internal xml
			
			if ( $request->getParam('format') == 'xerxes' )
			{
				$this->renderer->setFormat('xml');
			}
			
			// render based on template
			
			else
			{
				// determine which view script to use
				
				if ( $e->getResponse()->getStatusCode() != 200 )
				{
					$model->setVariable("display_exceptions", true);
					$model->setTemplate('error/index.phtml');
				}
				else
				{
					// determine which view script to use
					
					$script = $request->getControllerMap()->getView($request->getParam('format'));
					
					// test view chosen
					// header("Content-type: text/xml"); echo $request->getControllerMap()->saveXML();	echo "<!-- $script -->"; exit;
					
					$model->setTemplate($script);
				}
				
				// render it
				
				$display_as = "html";
				
				if ( $request->getParam('format') == 'json')
				{
					$display_as = "json";
				}
				
				$this->renderer->setFormat($display_as);
			}
			
			$this->enhanced = true;
		}
		
		return $this->renderer;
	}
	
	public function injectResponse($e)
	{
		$renderer = $e->getRenderer();
		$response = $e->getResponse();
		$result   = $e->getResult();
		
		if ( $renderer->getFormat() == "xml" )
		{
			$response->headers()->addHeaderLine("Content-type", "text/xml");
		}
		elseif ( $renderer->getFormat() == "json" )
		{
			$response->headers()->addHeaderLine("Content-type", "application/json");
		}
		
		### return the result
		
		$response->setContent($result);
		
		return $response;
	}
}
