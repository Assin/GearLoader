package org.gearloader.loader {
	import flash.net.URLLoaderDataFormat;
	
	public class GBinaryLoader extends GBaseLoader {
		
		public function GBinaryLoader() {
			super();
			dataFormat = URLLoaderDataFormat.BINARY;
		}
	}
}