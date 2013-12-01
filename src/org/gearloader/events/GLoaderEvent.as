package org.gearloader.events {
	import flash.events.Event;
	
	public class GLoaderEvent extends Event {
		/**
		 * GLoader load complete
		 */
		public static const COMPLETE:String = "complete";
		/**
		 * GLoader load error(ioError,securityError)
		 */
		public static const ERROR:String = "error";
		/**
		 * GLoader load in progress
		 */
		public static const PROGRESS:String = "progress";
		
		public var bytesLoaded:uint;
		public var bytesTotal:uint;
		public var errorType:String = "";
		public var content:*;
		public var currentFailTimes:int;
		public var url:String;
		public var name:String;
		public var status:String;
		
		public function GLoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}