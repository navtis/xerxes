<?php

namespace Application\Controller;

use Application\Model\Summon\Engine;

class SummonController extends SearchController
{
	protected $id = "summon";
	
	protected function getEngine()
	{
		return new Engine();
	}
}
