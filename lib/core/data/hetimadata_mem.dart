library hetimacore.mem;

import 'dart:async' as async;
import 'dart:core';
import 'hetimadata.dart';

class HetimaDataMemory extends HetimaData {
  bool get writable => true;
  bool get readable => true;

  List<int> _dataBuffer = null;
  HetimaDataMemory([List<int> buffer=null]) {
    if(buffer != null) {
      _dataBuffer = new List.from(buffer);
    } else {
      _dataBuffer = [];      
    }
  }

  String toDebug() {
    return "${_dataBuffer}";
  }

  List<int> getBuffer(int start, int length) {
    int end = start + length;
    if (end > _dataBuffer.length) {
      end = _dataBuffer.length;
    }
    return _dataBuffer.sublist(start, end);
  }

  async.Future<int> getLength() {
    async.Completer<int> comp = new async.Completer();
    comp.complete(_dataBuffer.length);
    return comp.future;
  }

  async.Future<WriteResult> write(Object buffer, int start, [int length=null]) {
    async.Completer<WriteResult> comp = new async.Completer();
    if (buffer is List<int>) {
      if (_dataBuffer.length < start) {
        _dataBuffer.addAll(new List.filled(start - _dataBuffer.length, 0));
      }

      if (length == null) {
        length = buffer.length;
      }
      for (int i = 0; i < length; i++) {
        if (start + i < _dataBuffer.length) {
          _dataBuffer[start + i] = buffer[i];
        } else {
          _dataBuffer.add(buffer[i]);
        }
      }
      comp.complete(new WriteResult());
    } else {
      // TODO
      throw new UnsupportedError("");
    }
    return comp.future;
  }

  async.Future<ReadResult> read(int offset, int length, {List<int> tmp:null}) {
    async.Completer<ReadResult> comp = new async.Completer();
    int end = offset + length;
    if (end > _dataBuffer.length) {
      end = _dataBuffer.length;
    }
    if (offset >= end) {
      comp.complete(new ReadResult([]));
    } else {
      comp.complete(new ReadResult(_dataBuffer.sublist(offset, end)));
    }
    return comp.future;
  }

  void beToReadOnly() {
    //
  }
}
