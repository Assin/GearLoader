package org.gearloader.loader{
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	public class GBaseLoader{
		protected var _urlLoader:URLLoader;
		protected var _urlRequest:URLRequest;
		protected var _currentFailTimes:int;
		
		public function GBaseLoader(){
			init();
		}

		protected function init():void{
			_urlLoader = new URLLoader();

		}

	}
}
