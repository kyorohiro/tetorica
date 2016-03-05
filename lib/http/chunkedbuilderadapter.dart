part of hetimanet_http;



class ChunkedBuilderAdapter extends TetReader {

  bool _started = false;
  ArrayBuilder _buffer = new ArrayBuilder();
  TetReader _base = null;

  ChunkedBuilderAdapter(TetReader builder) {
    _base = builder;
    start();
  }

  ChunkedBuilderAdapter start() {
    if (_started == true) {
      return this;
    }
    _started = true;
    _decodeChunked(new EasyParser(_base)).catchError((e) {
    }).then((e) {
      // print("\r\n#~55www#\r\n");
      _buffer.fin();
    });
    return this;
  }

  Future<bool> _decodeChunked(EasyParser parser) {
    Completer complter = new Completer();
    HetiHttpResponse.decodeChunkedSize(parser).then((int size) {
      return parser.buffer.getBytes(parser.index, size).then((List<int> v) {
        _buffer.appendIntList(v, 0, v.length);
        parser.index += v.length;
        if (v.length == 0) {
          complter.complete(true);
        } else {
          return HetiHttpResponse.decodeCrlf(parser).then((e) {
            // print("\r\n#~11www#\r\n");
            return _decodeChunked(parser);
          }).then((v) {
            complter.complete(true);
          });
        }
      });
    }).catchError((e) {
      complter.completeError(e);
    });
    return complter.future;
  }

  int get currentSize {
    return _buffer.currentSize;
  }
  Future<int> getLength() {
    return _buffer.getLength();
  }

  Completer<bool> get rawcompleterFin => _buffer.rawcompleterFin;

  Future<List<int>> getBytes(int index, int length, {List<int> out:null}) {
    return _buffer.getBytes(index, length, out:out);
  }
  Future<int> getIndex(int index, int length) {
    return _buffer.getIndex(index, length);
  }
  int operator [](int index) {
    return _base[index];
  }
}
