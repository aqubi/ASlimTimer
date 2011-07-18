package controller {

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.desktop.Updater;
import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLStream;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.utils.ByteArray;
import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import view.ProgressWindow;
/*
 * ASlimTimerのUpdateチェック
 * 最新Versionが記述されているXMLファイルをチェックし、更新があれば、
 * AirファイルをDownload,Updateを行なう。
 * ただ、現在は、controller.UpdateManager の方を使っているため、このクラスは使ってません。
  */
public class ASlimTimerUpdater {
		
private const VERSION_URL:String = "http://www.assembla.com/spaces/ASlimTimer/documents/bqUoAKBcOr3B8uab7jnrAJ/download/version.xml";
private var downloadFileName:String = "DownloadNewFile.air"; 
private var remoteVersion:String;
private var urlStream:URLStream;
private var completedFunction:Function;
private var popup:ProgressWindow;

/* VersionXMLにアクセスし、チェックをする */
public function checkUpdate(onCompleted:Function):void {
	completedFunction = onCompleted
	var versionLoader:URLLoader = new URLLoader();
	versionLoader.addEventListener(Event.COMPLETE, onVersionXmlLoaded);
	versionLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
	versionLoader.load(new URLRequest(VERSION_URL));	
}

private function onError(event:IOErrorEvent):void {
	completedFunction();
}

/* VersionXMLをダウンロードしてVersionをチェック */
private function onVersionXmlLoaded(event:Event):void {
	var xml:XML = new XML(event.target.data);
	remoteVersion = xml.version;

	var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var ns:Namespace = appDescriptor.namespace();
	var appVersion:String = appDescriptor.ns::version;

	if (remoteVersion != appVersion) {
		Alert.show("It is possible to update it to a new version. \n" +
					"Do you update it?\n\n" +
					"Now version: " + appVersion + "\n" +
					"New version: " + remoteVersion,
					'Confirm',
					Alert.YES | Alert.NO, null, 
				function (event:CloseEvent):void {
					if (event.detail == Alert.YES) {
						downloadNewPackage(xml.url);
					} else {
						completedFunction();
					}
				}
		);
	} else {
		completedFunction();
	}
}


/* Download NewPackage */
private function downloadNewPackage(urlString:String):void {
	popup = ProgressWindow(PopUpManager.createPopUp(DisplayObject(Application.application), ProgressWindow, true));
	PopUpManager.centerPopUp(popup);
	popup.title = "ASlimTimer Update";
	popup.progress.label = "download...";
	
	var urlReq:URLRequest = new URLRequest(urlString);
	urlStream = new URLStream();
	urlStream.addEventListener(Event.COMPLETE, loaded);
	urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError);
	popup.progress.source = urlStream;
	urlStream.load(urlReq);
}

private function loaded(event:Event):void {	
	var fileData:ByteArray = new ByteArray();
	urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
	writeAirFile(fileData);
}

private function writeAirFile(fileData:ByteArray):void {
	var file:File = File.applicationStorageDirectory.resolvePath(downloadFileName);
	var fileStream:FileStream = new FileStream();
	fileStream.open(file, FileMode.WRITE);
	fileStream.writeBytes(fileData, 0, fileData.length);
	fileStream.close();
	runUpdater(file);
}

private function runUpdater(airFile:File):void {
	var updater:Updater = new Updater();
	updater.update(airFile, remoteVersion);
	completedFunction();
	PopUpManager.removePopUp(popup);
	
}

}
}