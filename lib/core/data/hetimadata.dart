part of hetimacore;

abstract class HetimaDataBuilder {
  Future<HetimaData> createHetimaData(String path);
}

abstract class HetimaData implements HetimaFileReader, HetimaFileWriter {
  bool get writable => false;
  bool get readable => false;
  Future<int> getLength();
  Future<WriteResult> write(Object buffer, int start,[int length=null]);
  Future<ReadResult> read(int offset, int length, {List<int> tmp: null});
  void beToReadOnly();
}

abstract class HetimaFileWriter {
  Future<int> getLength();
  Future<WriteResult> write(Object o, int start,[int length=null]);
}

abstract class HetimaFileReader {
  Future<int> getLength();
  Future<ReadResult> read(int offset, int length);
}

class WriteResult {}

class ReadResult {
  List<int> buffer;
  int length = 0;
  ReadResult(List<int> _buffer, [int length = -1]) {
    buffer = _buffer;
    if (length < 0) {
      this.length = _buffer.length;
    } else {
      this.length = length;
    }
  }
}

class HetimaReaderToData extends HetimaData {
  HetimaReader mBuilder;
  HetimaReaderToData(HetimaReader builder) {
    mBuilder = builder;
  }
  @override
  Future<int> getLength() {
    return mBuilder.getLength();
  }

  @override
  Future<ReadResult> read(int offset, int length, {List<int> tmp: null}) {
    Completer<ReadResult> cc = new Completer();
    mBuilder.getByteFuture(offset, length).then((List<int> b) {
      ReadResult result = new ReadResult(new data.Uint8List.fromList(b));
      cc.complete(result);
    }).catchError((e) {
      cc.completeError(e);
    });
    return cc.future;
  }

  @override
  Future<WriteResult> write(Object buffer, int start,[int length=null]) {
    // todo
    return null;
  }

  void beToReadOnly() {
    mBuilder.fin();
  }
}

class HetimaDataToReader extends HetimaReader {
  HetimaData mFile;

  HetimaDataToReader(HetimaData f) {
    mFile = f;
  }

  @override
  Future<List<int>> getByteFuture(int index, int length, {List<int> buffer: null,List<int> output:null}) {
    Completer<List<int>> c = new Completer();
    mFile.read(index, length).then((ReadResult r) {
      List<int> b = r.buffer.toList();
      if(output != null) {
        if(output.length < 1) {
          output.add(b.length);
        } else {
          output[0] = b.length;
        }
      }
      c.complete(b);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }

  @override
  Future<int> getLength() {
    return mFile.getLength();
  }
}
