package org.gearloader.loader {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.gearloader.data.GLoaderError;
	import org.gearloader.data.GLoaderStatus;
	import org.gearloader.events.GLoaderEvent;
	
	public class GBaseLoader {
		protected static const TOTAL_FAIL_TIMES:int = 2;
		protected var _urlLoader:URLLoader;
		protected var _urlRequest:URLRequest;
		protected var _currentFailTimes:int;
		protected var _bytesLoaded:uint = 0;
		protected var _bytesTotal:uint = 0;
		protected var _loaderBytesTotal:uint = 0;
		protected var _autoDispose:Boolean = true;
		protected var _loadTime:uint;
		private var _startLoadStamp:uint;
		private var _url:String;
		private var _name:String = "";
		private var _status:String = GLoaderStatus.NONE;
		private var _content:*;
		private var _onCompleteArray:Array;
		private var _onProgressArray:Array;
		private var _onErrorArray:Array;
		
		/**
		 * get load used time
		 */
		public function get loadTime():uint{
			return _loadTime;
		}

		/**
		 * setting auto dispose GLoader when load complete
		 */
		public function get autoDispose():Boolean{
			return _autoDispose;
		}

		/**
		 * setting auto dispose GLoader when load complete
		 */
		public function set autoDispose(value:Boolean):void{
			_autoDispose = value;
		}

		/**
		 * setting this attribute before load start
		 * if loaderByteTotal not equals 0,then use for the bytesTotal variable on ProgressEvent and CompleteEvent's data verify.
		 */
		public function get loaderBytesTotal():uint {
			return _loaderBytesTotal;
		}
		
		/**
		 * setting this attribute before load start
		 * if loaderByteTotal not equals 0,then use for the bytesTotal variable on ProgressEvent and CompleteEvent's data verify.
		 */
		public function set loaderBytesTotal(value:uint):void {
			_loaderBytesTotal = value;
		}
		
		public function GBaseLoader() {
			init();
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
		
		public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		public function get content():* {
			return _content;
		}
		
		public function set content(value:*):void {
			_content = value;
		}
		
		public function get status():String {
			return _status;
		}
		
		public function set status(value:String):void {
			_status = value;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set url(value:String):void {
			_url = value;
			
			if (_urlRequest) {
				_urlRequest.url = _url;
			}
		}
		
		protected function init():void {
			_urlLoader = new URLLoader();
			_urlRequest = new URLRequest();
			_urlRequest.url = _url;
		}
		
		protected function set dataFormat(value:String):void {
			if (!_urlLoader) {
				return ;
			}
			_urlLoader.dataFormat = value;
		}
		
		public function load():void {
			if (!_urlLoader || !_urlRequest) {
				return ;
			}
			
			if (_urlRequest.url == null || _urlRequest.url == "") {
				return ;
			}
			addURLLoaderEventListener();
			//set the status is GLoaderStatus.PROGRESS
			status = GLoaderStatus.PROGRESS;
			_loadTime = 0;
			_startLoadStamp = getTimer();
			_urlLoader.load(_urlRequest);
		}
		
		public function close():void {
			status = GLoaderStatus.NONE;
			
			if (!_urlLoader) {
				return ;
			}
			_urlLoader.close();
		}
		
		protected function addURLLoaderEventListener():void {
			_urlLoader.addEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onURLLoaderProgressHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOErrorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityErrorHandler);
		}
		
		protected function removeURLLoaderEventListener():void {
			_urlLoader.removeEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, onURLLoaderProgressHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOErrorHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityErrorHandler);
		}
		
		protected function onURLLoaderCompleteHandler(e:Event):void {
			removeURLLoaderEventListener();
			if (_loaderBytesTotal == 0 || (_loaderBytesTotal != 0 && _bytesLoaded == _loaderBytesTotal)) {
				// load complete
				status = GLoaderStatus.COMPLETE;
				_content = _urlLoader.data;
				_loadTime = getTimer() - _startLoadStamp;
				executeCompleteAfterHandler();
				status = GLoaderStatus.NONE;
				if(_autoDispose){
					dispose();
				}
			} else {
				//bytesLoaded size not equals bytesTotal.
				//switch to execute error
				status = GLoaderStatus.ERROR;
				_currentFailTimes++;
				trace("[GLoader][DataError] Name:" + _name + " URL:" + _url + " currentFailTimes:" +
					_currentFailTimes);
				executeErrorAfterHandler(GLoaderError.DATA_ERROR);
			}
		}
		
		protected function onURLLoaderProgressHandler(e:ProgressEvent):void {
			if (_loaderBytesTotal == 0) {
				_bytesTotal = e.bytesTotal;
			}
			_bytesLoaded = e.bytesLoaded;
			executeProgressAfterHandler();
		}
		
		protected function onURLLoaderIOErrorHandler(e:IOErrorEvent):void {
			status = GLoaderStatus.ERROR;
			_loadTime = getTimer() - _startLoadStamp;
			_currentFailTimes++;
			trace("[GLoader][IOError] Name:" + _name + " URL:" + _url + " currentFailTimes:" +
				_currentFailTimes);
			if(_currentFailTimes >= TOTAL_FAIL_TIMES){
				//if load fail times equals TOTAL_FAIL_TIMES value,then executeError
				executeErrorAfterHandler(GLoaderError.IO_ERROR);				
				if(_autoDispose){
					dispose();
				}
			}else{
				//if load fail times not less than TOTAL_FAIL_TIMES,then keep load
				load();
			}

		}
		
		protected function onURLLoaderSecurityErrorHandler(e:SecurityErrorEvent):void {
			status = GLoaderStatus.ERROR;
			_loadTime = getTimer() - _startLoadStamp;
			_currentFailTimes++;
			trace("[GLoader][SecurityError] Name:" + _name + " URL:" + _url + " currentFailTimes:" +
				_currentFailTimes);
			if(_currentFailTimes >= TOTAL_FAIL_TIMES){
				//if load fail times equals TOTAL_FAIL_TIMES value,then executeError
				executeErrorAfterHandler(GLoaderError.SECURITY_ERROR);
				if(_autoDispose){
					dispose();
				}
			}else{
				//if load fail times not less than TOTAL_FAIL_TIMES,then keep load
				load();
			}
		}
		
		protected function executeCompleteAfterHandler():void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.COMPLETE);
			event.content = _content;
			event.currentFailTimes = _currentFailTimes;
			event.url = _url;
			event.name = _name;
			event.status = _status;
			
			for each(var callBack:Function in _onCompleteArray){
				if(callBack){
					callBack(event);
				}
			}
		}
		
		protected function executeProgressAfterHandler():void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.PROGRESS);
			event.bytesLoaded = _bytesLoaded;
			event.bytesTotal = _bytesTotal;
			event.currentFailTimes = _currentFailTimes;
			event.url = _url;
			event.name = _name;
			event.status = _status;
			
			for each(var callBack:Function in _onProgressArray){
				if(callBack){
					callBack(event);
				}
			}
		}
		
		protected function executeErrorAfterHandler(errorType:String):void {
			var event:GLoaderEvent = new GLoaderEvent(GLoaderEvent.ERROR);
			event.errorType = errorType;
			event.currentFailTimes = _currentFailTimes;
			event.url = _url;
			event.name = _name;
			event.status = _status;
			
			for each(var callBack:Function in _onErrorArray){
				if(callBack){
					callBack(event);
				}
			}
		}
		
		public function dispose():void {
			removeURLLoaderEventListener();
			close();
			_urlLoader = null;
			_urlRequest = null;
			_content = null;
			_onComplete = null;
			_onProgress = null;
			_onError = null;
		}
	}
}
