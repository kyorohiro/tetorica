library hetimacore_cl.get;
import 'dart:async' as async;
import 'dart:core';
import 'dart:html' as html;
import '../../hetimacore.dart';

class HetimaDataGet extends HetimaData {

  html.Blob _mBlob = null;
  String _mPath = "";

  bool get writable => false;
  bool get readable => true;

  HetimaDataGet(String path) {
    _mPath = path;
  }

  async.Future<WriteResult> write(Object buffer, int start, [int length=null]) {
    return new async.Completer<WriteResult>().future;
  }

  async.Future<html.Blob> getBlob() {
    async.Completer<html.Blob> ret = new async.Completer();
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", _mPath);
    request.onLoad.listen((html.ProgressEvent e) {
      _mBlob = request.response;
      ret.complete(request.response);
    });
    request.send();
    return ret.future;
  }

  async.Future<int> getLength() {
    async.Completer<int> ret = new async.Completer();
    if (_mBlob == null) {
      getBlob().then((html.Blob b) {
          ret.complete(b.size);          
      });
    } else {
      ret.complete(_mBlob.size);
    }
    return ret.future;
  }

  async.Future<ReadResult> read(int offset, int length, {List<int> tmp:null}){
    async.Completer<ReadResult> ret = new async.Completer<ReadResult>();
    if (_mBlob != null) {
        return readBase(ret, offset, length);
    } else {
      getBlob().then((html.Blob b) {
        readBase(ret, offset, length);
      });
      return ret.future;
    }
  }

  async.Future<ReadResult> readBase(async.Completer<ReadResult> ret, int start, int end) {
    html.FileReader reader = new html.FileReader();
    reader.onLoad.listen((html.ProgressEvent e) {
      ret.complete(new ReadResult(reader.result));
    });
    reader.onError.listen((html.Event e) {
      ret.completeError("error");
    });
    reader.onAbort.listen((html.ProgressEvent e) {
      ret.completeError("abort");
    });
    reader.readAsArrayBuffer(_mBlob.slice(start, end));
    return ret.future;
  }

  void beToReadOnly() {    
  }

}
