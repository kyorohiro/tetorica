library hetimanet.http.response.chunk;

import 'dart:async' as async;
import 'package:tetorica/core.dart';
import 'hetihttpresponse.dart';


class ChunkedBuilderAdapter extends HetimaReader {

  bool _started = false;
  ArrayBuilder _buffer = new ArrayBuilder();
  HetimaReader _base = null;
  ChunkedBuilderAdapter(HetimaReader builder) {
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

  async.Future<bool> _decodeChunked(EasyParser parser) {
    async.Completer complter = new async.Completer();
    HetiHttpResponse.decodeChunkedSize(parser).then((int size) {
      return parser.buffer.getByteFuture(parser.index, size).then((List<int> v) {
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

  async.Future<int> getLength() {
    return _buffer.getLength();
  }

  async.Completer<bool> get rawcompleterFin => _buffer.rawcompleterFin;

  async.Future<List<int>> getByteFuture(int index, int length, {List<int> buffer: null, List<int> output:null}) {
    return _buffer.getByteFuture(index, length, buffer:buffer, output:output);
  }
}
