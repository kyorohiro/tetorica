library hetimacore_cl.blob;
import 'dart:async' as async;
import 'dart:core';
import 'dart:html' as html;
import '../../hetimacore.dart';



class HetimaDataBlob extends HetimaData {
  html.Blob _mBlob;
  HetimaFileWriter _mWriter;

  bool get writable => (_mWriter == true);
  bool get readable => true;

  HetimaDataBlob(bl, [HetimaFileWriter writer = null]) {
    _mBlob = bl;
    _mWriter = writer;
  }

  async.Future<int> getLength() {
    async.Completer<int> ret = new async.Completer();
    ret.complete(_mBlob.size);
    return ret.future;
  }

  async.Future<WriteResult> write(Object o, int start,[int length=null]) {
    return _mWriter.write(o, start, length);
  }


  async.Future<ReadResult> read(int offset, int length, {List<int> tmp:null}) {
    async.Completer<ReadResult> ret = new async.Completer<ReadResult>();
    async.StreamSubscription a = null;
    async.StreamSubscription b = null;
    async.StreamSubscription c = null;
    html.FileReader reader = new html.FileReader();
    a = reader.onLoadEnd.listen((html.ProgressEvent e) {
      ret.complete(new ReadResult(reader.result));
      a.cancel();
      b.cancel();
      c.cancel();
      reader = null;
      a = null;
      b = null;
      c = null;
      ret = null;
    });
    b = reader.onError.listen((html.Event e) {
      print("read error : ${e}");
      ret.completeError("error");
    });
    c = reader.onAbort.listen((html.ProgressEvent e) {
      print("read abort : ${e}");
      ret.completeError("abort");
    });
    reader.readAsArrayBuffer(_mBlob.slice(offset, offset+length));
    return ret.future;
  }

  void beToReadOnly() {
  }
}

