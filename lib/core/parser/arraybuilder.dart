library hetimacore.array;

import 'dart:typed_data' as data;
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:core';
import 'hetimareader.dart';
import 'arraybuilderbuffer.dart';

class ArrayBuilder extends HetimaReader {
  int _max = 1024;
  ArrayBuilderBuffer _buffer8;
  ArrayBuilderBuffer get rawbuffer8 => _buffer8;
  int _length = 0;
  List<GetByteFutureInfo> mGetByteFutreList = new List();

  int get clearedBuffer => _buffer8.clearedBuffer;

  bool logon = false;
  ArrayBuilder({bufferSize: 1024}) {
    this.logon = logon;
    _max = bufferSize;
    _buffer8 = new ArrayBuilderBuffer(_max); //new data.Uint8List(_max);
  }

  ArrayBuilder.fromList(List<int> buffer, [isFin = false]) {
    _buffer8 = new ArrayBuilderBuffer.fromList(buffer);
    _length = buffer.length;
    if (isFin == true) {
      fin();
    }
  }

  bool _updateGetInfo(GetByteFutureInfo info) {
    if (this.immutable == true || info.completerResult != null && info.index + info.completerResultLength - 1 < _length) {
      int length = 0;
      for (int i = 0; i < info.completerResultLength && info.index + i < size(); i++) {
        info.completerResult[i] = _buffer8[info.index + i];
        length += 1;
      }

      if (info.output == null && info.completerResult.length > length) {
        List<int> k = info.completerResult.sublist(0, length);
        info.completerResult = k;
      }
      info.completer.complete(info.completerResult);
      info.completerResult = null;
      info.completerResultLength = 0;
      if(info.output != null) {
        if(info.output.length < 1) {
          info.output.add(length);
        } else {
          info.output[0] = length;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  void _updateGetInfos() {
    List<GetByteFutureInfo> removeList = new List();
    for (GetByteFutureInfo f in mGetByteFutreList) {
      if (true == _updateGetInfo(f)) {
        removeList.add(f);
      }
    }
    for (GetByteFutureInfo f in removeList) {
      mGetByteFutreList.remove(f);
    }
  }

  Future<List<int>> getByteFuture(int index, int length, {List<int> buffer: null, List<int> output:null}) {
    GetByteFutureInfo info = new GetByteFutureInfo();
    if (buffer == null) {
      info.completerResult = new data.Uint8List(length);
    } else {
      info.completerResult = buffer;
    }
    info.output = output;
    if (info.completerResult.length < length) {
      throw {};
    }

    info.completerResultLength = length;
    info.index = index;
    info.completer = new Completer();

    if (false == _updateGetInfo(info)) {
      mGetByteFutreList.add(info);
    }

    return info.completer.future;
  }

  int operator [](int index) => 0xFF & _buffer8[index];

  int get(int index) => 0xFF & _buffer8[index];

  void clear() {
    _length = 0;
  }

  void clearInnerBuffer(int len, {reuse: true}) {
    _buffer8.clearInnerBuffer(len, reuse: reuse);
  }

  int size() {
    return _length;
  }

  Future<int> getLength() async {
    return _length;
  }

  void update(int plusLength) {
    if (_length + plusLength < _max) {
      return;
    } else {
      int nextMax = _length + plusLength + (_max-_buffer8.clearedBuffer);
      _buffer8.expand(nextMax);
      _max = nextMax;
    }
  }

  void fin() {
    immutable = true;
    _updateGetInfos();
    mGetByteFutreList.clear();
  }

  void appendByte(int v) {
    if (immutable) {
      return;
    }
    update(1);
    _buffer8[_length] = v;
    _length += 1;

    _updateGetInfos();
  }

  void appendIntList(List<int> buffer, [int index = 0, int length = -1]) {
    if (immutable) {
      return;
    }
    if (length < 0) {
      length = buffer.length;
    }
    update(length);

    for (int i = 0; i < length; i++) {
      _buffer8[_length + i] = buffer[index + i];
    }
    _length += length;
    _updateGetInfos();
  }

  void appendString(String text) => appendIntList(convert.UTF8.encode(text));

  List toList() => _buffer8.sublist(0, _length);

  data.Uint8List toUint8List() => new data.Uint8List.fromList(toList());

  String toText() => convert.UTF8.decode(toList());
}

class GetByteFutureInfo {
  List<int> completerResult = new List();
  int completerResultLength = 0;
  int index = 0;
  List<int> output = null;
  Completer<List<int>> completer = null;
}
