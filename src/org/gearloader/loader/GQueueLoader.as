package org.gearloader.loader {
	import org.gearloader.events.GLoaderEvent;
	
	public class GQueueLoader {
		/**
		 * max loader connection in a Batch
		 */
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
		private var _loadingLoaderArray:Array;
		
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
		}
		
		/**
		 * set error call back method
		 * @param value
		 *
		 */
		public function set onError(value:Function):void {
			if (value == null) {
				return ;
			}
			
			if (!_onErrorArray) {
				_onErrorArray = [];
			}
			_onErrorArray.push(value);
		}
		
		/**
		 * set progress call back method
		 * @param value
		 *
		 */
		public function set onProgress(value:Function):void {
			if (value == null) {
				return ;
			}
			
			if (!_onProgressArray) {
				_onProgressArray = [];
			}
			_onProgressArray.push(value);
		}
		
		/**
		 * set complete call back method
		 * @param value
		 *
		 */
		public function set onComplete(value:Function):void {
			if (value == null) {
				return ;
			}
			
			if (!_onCompleteArray) {
				_onCompleteArray = [];
			}
			_onCompleteArray.push(value);
		}
		
		/**
		 * return queue loading status
		 * @return
		 *
		 */
		public function get isLoading():Boolean {
			return _isLoading;
		}
		
		public function GQueueLoader() {
			_queue = [];
			_loadingLoaderArray = [];
		}
		
		/**
		 * add a loader to queue
		 * @param loader
		 *
		 */
		public function addLoader(loader:GBaseLoader):void {
			if (!_queue) {
				return ;
			}
			_queue.push(loader);
			_totalLoadCount = _queue.length;
		}
		
		/**
		 * add a loader to queue and load at once
		 * @param loader
		 *
		 */
		public function addLoaderAndLoad(loader:GBaseLoader):void {
			if (!_queue) {
				return ;
			}
			_queue.push(loader);
			_totalLoadCount = _queue.length;
			load();
		}
		
		public function load():void {
			if (_isLoading) {
				return ;
			}
			
			if (!_queue || _queue.length == 0) {
				return ;
			}
			var nextLoaderCount:int = Math.min(_queue.length, maxConnection);
			_currentBatchLoaderCount = nextLoaderCount;
			_currentBatchLoadCompleteCount = 0;
			
			while (nextLoaderCount > 0) {
				var loader:GBaseLoader = _queue.shift();
				_loadingLoaderArray.push(loader);
				loadItem(loader);
				--nextLoaderCount;
			}
		}
		
		protected function loadItem(loader:GBaseLoader):void {
			if (!loader) {
				return ;
			}
			
			if (!_isLoading) {
				_isLoading = true;
			}
			loader.onComplete = onLoadItemCompleteHandler;
			loader.onError = onLoadItemErrorHandler;
			loader.onProgress = onLoadItemProgressHandler;
			loader.load();
		}
		
		//load item complete in queue
		protected function onLoadItemCompleteHandler(e:GLoaderEvent):void {
			//delete complete loader from "_loadingLoaderArray"
			_loadingLoaderArray.splice(_loadingLoaderArray.indexOf(e.item), 1);
			//record complete count
			++_currentBatchLoadCompleteCount;
			//add this attribute ,must be before checkCurrentBatchStatus method
			++_currentLoadedCount;
			checkCurrentBatchStatus();
		}
		
		//load item has been error
		protected function onLoadItemErrorHandler(e:GLoaderEvent):void {
			//delete complete loader from "_loadingLoaderArray"
			_loadingLoaderArray.splice(_loadingLoaderArray.indexOf(e.item), 1);
			//record complete count
			++_currentBatchLoadCompleteCount;
			//if load item has been error
			//execute queue error handler
			executeErrorHandler();
			checkCurrentBatchStatus();
		}
		
		//load item has been progress,every item can trigger this callback handler
		protected function onLoadItemProgressHandler(e:GLoaderEvent):void {
			//execute progress handler
			executeProgressHandler();
		}
		
		//check current batch load status, if current batch load complete then continue load next batch
		protected function checkCurrentBatchStatus():void {
			//all loader has been complete in current Batch
			if (_currentBatchLoadCompleteCount >= _currentBatchLoaderCount) {
				_isLoading = false;
				_currentBatchLoaderCount = 0;
				_currentBatchLoadCompleteCount = 0;
				
				//continue load next Batch if they has
				if (_queue.length > 0) {
					load();
				} else {
					//load queue all complete, execute queue Complete Handler
					executeCompleteHandler();
				}
			}
		}
		
		protected function executeCompleteHandler():void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.COMPLETE);
			event.name = _name;
			
			for each (var callBack:Function in _onCompleteArray) {
				if (callBack != null) {
					callBack(event);
				}
			}
		}
		
		protected function executeProgressHandler():void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.PROGRESS);
			event.name = _name;
			event.queueTotal = _totalLoadCount;
			event.queueCurrent = _currentLoadedCount;
			event.rawProgress = _currentLoadedCount / _totalLoadCount;
			
			//calculate load queue raw progress,from all loading loader progress
			var totalRawProgress:Number = _totalLoadCount;
			var loadedRawProgress:Number = 0;
			var totalRate:int = 0;
			var totalRateCount:int = 0;
			if (_loadingLoaderArray) {
				for each (var loader:GBaseLoader in _loadingLoaderArray) {
					loadedRawProgress += loader.rawProgress;
					var loaderRate:int = loader.loadRate;
					if(loaderRate != 0)
					{
						totalRate += loaderRate;
						totalRateCount++;
					}
				}
			}
			event.loadRate = totalRate / totalRateCount;
			event.progress = (loadedRawProgress + _currentLoadedCount) / totalRawProgress;
			
			
			for each (var callBack:Function in _onProgressArray) {
				if (callBack != null) {
					callBack(event);
				}
			}
		}
		
		protected function executeErrorHandler():void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.ERROR);
			event.name = _name;
			
			for each (var callBack:Function in _onErrorArray) {
				if (callBack != null) {
					callBack(event);
				}
			}
		}
		
		public function dispose():void {
			//dipose function
			_isLoading = false;
			
			for each (var loader:GBaseLoader in _queue) {
				loader.dispose();
				loader = null;
			}
			_queue = null;
			_onCompleteArray = null;
			_onProgressArray = null;
			_onErrorArray = null;
			_loadingLoaderArray = null;
		}
	}
}
