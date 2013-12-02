package org.gearloader.loader {
	import flash.net.URLLoaderDataFormat;
	
	public class GTextLoader extends GBaseLoader {
		
		public function GTextLoader() {
			super();
			dataFormat = URLLoaderDataFormat.TEXT;
		}
	}
}