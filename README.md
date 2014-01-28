GearLoader
==========

ActionScript Loader component<br>
  used to load static resouces<br>
  such as image(png,jpg),swf,txt,binaryData<br>



Examples
==========
  Load a bitmap file:
    
    var loader:GImageLoader = new GImageLoader();
    //google logo , for test
    loader.url = "http://www.google.com/images/nav_logo170_hr.png";
    loader.onProgress = onProgressHandler;
    loader.onComplete = onCompleteHandler;
    loader.load();
    
    function onProgressHandler(e:GLoaderEvent):void{
      	trace(e.progress);
    }
    
    function onCompleteHandler(e:GLoaderEvent):void{
    	 var bitmapData:BitmapData = GImageLoader(e.item).getBitmapData();
    }
    
  Load a xml file:
  
  	var loader:GImageLoader = new GImageLoader();
    //google logo , for test
    loader.url = "http://www.google.com/images/nav_logo170_hr.png";
    loader.onProgress = onProgressHandler;
    loader.onComplete = onCompleteHandler;
    loader.load();
    
    function onProgressHandler(e:GLoaderEvent):void{
      	trace(e.progress);
    }
    
    function onCompleteHandler(e:GLoaderEvent):void{
    	 var bitmapData:BitmapData = GImageLoader(e.item).getBitmapData();
    }
  
  
