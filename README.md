GearLoader
==========

ActionScript Loader component<br>
  used to load static resouces<br>
  such as image(png,jpg),swf,txt,binaryData<br>
  this project no used static funcitons. need new class to load.
  Tiny Loader components,flexible in your project.
  


Examples
==========
  Load a bitmap file:
    
    var imageLoader:GImageLoader = new GImageLoader();
    //google logo , for test
    imageLoader.url = "http://www.google.com/images/nav_logo170_hr.png";
    imageLoader.onProgress = onProgressHandler;
    imageLoader.onComplete = onCompleteHandler;
    imageLoader.load();
    
    function onProgressHandler(e:GLoaderEvent):void{
      	trace(e.progress);
      	trace(e.loadRate);    // download rate
    }
    
    function onCompleteHandler(e:GLoaderEvent):void{
    	 var bitmapData:BitmapData = GImageLoader(e.item).getBitmapData();
    }
    
  Load a xml file:
  
  	var textLoader:GTextLoader = new GTextLoader();
    //google news RSS, for test
    textLoader.url = "http://news.google.com/?output=rss";
    textLoader.onProgress = onProgressHandler;
    textLoader.onComplete = onCompleteHandler;
    textLoader.load();
    
    function onProgressHandler(e:GLoaderEvent):void{
      	trace(e.progress);
      	trace(e.loadRate);    // download rate
    }
    
    function onCompleteHandler(e:GLoaderEvent):void{
    	 var xml:XML = new XML(e.content as String);
    }
  
  Load files by queue:
  
    var loaderQueue:GQueueLoader = new GQueueLoader();
    //use before loader
    loaderQueue.addLoader(imageLoader);
    loaderQueue.addLoader(textLoader);
    loaderQueue.onProgress = onQueueProgressHandler;
    loaderQueue.onComplete = onQueueCompleteHandler;
    loaderQueue.load();
    
    function onQueueProgressHandler(e:GLoaderEvent):void{
      trace(e.rawProgress); // queueLoader's loaded file count progress
      trace(e.progress);    // queueLoader's loaded file bytes progress
      trace(e.loadRate);    // download rate
    }
    
    function onQueueCompleteHandler(e:GLoaderEvent):void{
      trace("Queue loaded complete!");
    }
  
