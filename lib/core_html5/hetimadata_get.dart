part of hetimacore_cl;


class HetimaDataGet extends HetimaData {

  html.Blob _mBlob = null;
  String _mPath = "";

  bool get writable => false;
  bool get readable => true;

  HetimaDataGet(String path) {
    _mPath = path;
  }

  Future<WriteResult> write(Object buffer, int start, [int length=null]) {
    return new Completer<WriteResult>().future;
  }

  Future<html.Blob> getBlob() {
    Completer<html.Blob> ret = new Completer();
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

  Future<int> getLength() {
    Completer<int> ret = new Completer();
    if (_mBlob == null) {
      getBlob().then((html.Blob b) {
          ret.complete(b.size);
      });
    } else {
      ret.complete(_mBlob.size);
    }
    return ret.future;
  }

  Future<ReadResult> read(int offset, int length, {List<int> tmp:null}){
    Completer<ReadResult> ret = new Completer<ReadResult>();
    if (_mBlob != null) {
        return readBase(ret, offset, length);
    } else {
      getBlob().then((html.Blob b) {
        readBase(ret, offset, length);
      });
      return ret.future;
    }
  }

  Future<ReadResult> readBase(Completer<ReadResult> ret, int start, int end) {
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
