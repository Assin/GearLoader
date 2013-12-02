package org.gearloader.loader{
	import org.gearloader.events.GLoaderEvent;

	public class GQueueLoader{
		public var maxConnection:uint = 8;
		protected var _name:String = "";
		protected var _isLoading:Boolean;
		protected var _queue:Array;
		protected var _currentLoadedCount:uint;
		protected var _totalLoadCount:uint;
		protected var _currentBatchLoaderCount:int;
		protected var _currentBatchLoadCompleteCount:int;
		private var _onCompleteArray:Array;
		private var _onProgressArray:Array;
		private var _onErrorArray:Array;

		public function get name():String{
			return _name;
		}

		public function set name(value:String):void{
			_name = value;
		}

		public function set onError(value:Function):void {
			if(!value){
				return;
			}
			if(!_onErrorArray){
				_onErrorArray = [];
			}
			_onErrorArray.push(value);
		}
		
		public function set onProgress(value:Function):void {
			if(!value){
				return;
			}
			if(!_onProgressArray){
				_onProgressArray = [];
			}
			_onProgressArray.push(value);
		}
		
		public function set onComplete(value:Function):void {
			if(!value){
				return;
			}
			if(!_onCompleteArray){
				_onCompleteArray = [];
			}
			_onCompleteArray.push(value);
		}	

		public function get isLoading():Boolean{
			return _isLoading;
		}

		public function GQueueLoader(){
			_queue = [];
		}
		
		public function addLoader(loader:GBaseLoader):void{
			if(!_queue){
				return;
			}
			_queue.push(loader);
			_totalLoadCount = _queue.length;
		}

		public function addLoaderAndLoad(loader:GBaseLoader):void{
			if(!_queue){
				return;
			}
			_queue.push(loader);
			_totalLoadCount = _queue.length;
			load();
		}

		public function load():void{
			if(_isLoading){
				return;
			}
			if(!_queue || _queue.length == 0){
				return;
			}
			var nextLoaderCount:int = Math.min(_queue.length, maxConnection);
			_currentBatchLoaderCount = nextLoaderCount;
			_currentBatchLoadCompleteCount = 0;
			while(nextLoaderCount > 0){
				loadItem(_queue.shift());
				--nextLoaderCount;
			}
		}

		protected function loadItem(loader:GBaseLoader):void{
			if(!loader){
				return;
			}
			if(!_isLoading){
				_isLoading = true;
			}
			loader.onComplete = onLoadItemCompleteHandler;
			loader.onError = onLoadItemErrorHandler;
			loader.load();
		}

		//load item complete in queue
		protected function onLoadItemCompleteHandler(e:GLoaderEvent):void{
			++_currentBatchLoadCompleteCount;
			//add this attribute ,must be befor checkCurrentBatchStatus method
			++_currentLoadedCount;
			//execute progress handler
			executeProgressHandler();
			checkCurrentBatchStatus();
		}

		//load item has been error
		protected function onLoadItemErrorHandler(e:GLoaderEvent):void{
			//if load item has been error
			//execute queue error handler
			executeErrorHandler();
		}

		//check current batch load status, if current batch load complete then continue load next batch
		protected function checkCurrentBatchStatus():void{
			//all loader has been complete in current Batch
			if(_currentBatchLoadCompleteCount >= _currentBatchLoaderCount){
				_isLoading = false;
				_currentLoadedCount = 0;
				_currentBatchLoaderCount = 0;
				_currentBatchLoadCompleteCount = 0;
				//continue load next Batch if they has
				if(_queue.length > 0){
					load();
				}else{
					//load queue all complete, execute queue Complete Handler
					executeCompleteHandler();
				}
			}
		}

		protected function executeCompleteHandler():void{
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.COMPLETE);
			event.name = _name;

			for each(var callBack:Function in _onCompleteArray){
				if(callBack){
					callBack(event);
				}
			}
		}

		protected function executeProgressHandler():void{
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.PROGRESS);
			event.name = _name;
			event.queueTotal = _totalLoadCount;
			event.queueCurrent = _currentLoadedCount;
			event.progress = _currentLoadedCount / _totalLoadCount;

			for each(var callBack:Function in _onProgressArray){
				if(callBack){
					callBack(event);
				}
			}
		}

		protected function executeErrorHandler():void{
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.ERROR);
			event.name = _name;

			for each(var callBack:Function in _onErrorArray){
				if(callBack){
					callBack(event);
				}
			}
		}

		public function dispose():void{
			//dipose function
			_isLoading = false;
			for each(var loader:GBaseLoader in _queue){
				loader.dispose();
				loader = null;
			}
			_queue = null;
			_onCompleteArray = null;
			_onProgressArray = null;
			_onErrorArray = null;
		}
	}
}
