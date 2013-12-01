package org.gearloader.loader {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class GImageLoader extends GDisplayObjectLoader {
		protected var _bitmapData:BitmapData;
		protected var _isClone:Boolean;
		
		public function GImageLoader() {
			super();
		}
		
		public function getBitmapData(clone:Boolean = false):BitmapData {
			_isClone = clone;
			
			if (!_bitmapData) {
				return null;
			}
			
			if (_isClone) {
				return _bitmapData.clone();
			} else {
				return _bitmapData;
			}
		}
		
		override protected function executeLoaderCompleteAfterHandler():void {
			_bitmapData = (content as Bitmap).bitmapData;
			super.executeLoaderCompleteAfterHandler();
		}
		
		override public function dispose():void {
			if (_bitmapData && _isClone) {
				_bitmapData.dispose();
			}
			_bitmapData = null;
			super.dispose();
		}
		
		
	}
}