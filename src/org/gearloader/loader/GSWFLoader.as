package org.gearloader.loader {
	import flash.display.MovieClip;
	
	public class GSWFLoader extends GDisplayObjectLoader {
		private var _movieClip:MovieClip;
		
		public function GSWFLoader() {
			super();
		}
		
		override protected function executeLoaderCompleteAfterHandler():void {
			_movieClip = content as MovieClip;
			_movieClip.stop();
			super.executeLoaderCompleteAfterHandler();
		}
		
		override public function dispose():void {
			_movieClip = null;
			super.dispose();
		}
		
		
	}
}