package org.gearloader.data {
	
	public class GLoaderStatus {
		/**
		 * when the GLoader to do anything
		 */
		public static const NONE:String = "none";
		/**
		 * when the GLoader in loading progress
		 */
		public static const PROGRESS:String = "progress";
		/**
		 * when the GLoader was load complete
		 */
		public static const COMPLETE:String = "complete";
		/**
		 * when the GLoader was happend some error, such as IOError,SecurityError
		 */
		public static const ERROR:String = "error";
		
	}
}