part of hetimacore_cl;


class HetimaDataBlob extends HetimaData {
  html.Blob _mBlob;
  HetimaFileWriter _mWriter;

  bool get writable => (_mWriter == true);
  bool get readable => true;

  HetimaDataBlob(bl, [HetimaFileWriter writer = null]) {
    _mBlob = bl;
    _mWriter = writer;
  }

  Future<int> getLength() {
    Completer<int> ret = new Completer();
    ret.complete(_mBlob.size);
    return ret.future;
  }

  Future<WriteResult> write(Object o, int start,[int length=null]) {
    return _mWriter.write(o, start, length);
  }


  Future<ReadResult> read(int offset, int length, {List<int> tmp:null}) {
    Completer<ReadResult> ret = new Completer<ReadResult>();
    StreamSubscription a = null;
    StreamSubscription b = null;
    StreamSubscription c = null;
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
