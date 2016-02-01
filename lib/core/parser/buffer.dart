part of hetimacore;

class TetBuffer {
  int _clearBuffer = 0;
  int _length = 0;
  int get clearBuffer => _clearBuffer;

  List<int> _buffer8 = null;
  List<int> get rawbuffer8 => _buffer8;

  int get clearedBuffer => _clearBuffer;
  bool logon = false;

  TetBuffer(int max) {
    _length = max;
    _buffer8 = new data.Uint8List(max);
  }

  TetBuffer.fromList(List<int> buffer) {
    _length = buffer.length;
    _buffer8 = new data.Uint8List.fromList(buffer);
  }

  int operator [](int index) {
    return ((index - _clearBuffer >= 0)?_buffer8[index - _clearBuffer]:0);
  }

  void operator []=(int index, int value) {
    if (index  >= _clearBuffer) {
      _buffer8[index - _clearBuffer] = value;
    }
  }

  List<int> sublist(int start, int end) {
    data.Uint8List ret = new data.Uint8List(end - start);
    for (int j = 0; j < end - start; j++) {
      ret[j] = this[j + start];
    }
    return ret;
  }

  void clearInnerBuffer(int len, {bool reuse: true}) {
    if (_clearBuffer >= len) {
      if(logon) {
        print("(_clearedBuffer >= len) == (${_clearBuffer} >= ${len})");
      }
      return;
    }

    if (length < len) {
      if(logon) {
        print("(length < len) == (${length} < ${len})");
      }
      return;
    }

    int erace = len - _clearBuffer;
    if(logon) {
      print("(int erace = len - _clearedBuffer) == ${erace} = ${len} - ${_clearBuffer})");
    }
    if (reuse == false) {
      _buffer8 = _buffer8.sublist(erace);
      _length = _buffer8.length;
    } else {
      for (int i = 0; i + erace < _length; i++) {
        _buffer8[i] = _buffer8[i+erace];
      }
      _length = _length-erace;
    }
    if(logon) {
      print("(_length) == ${erace} = ${_length})");
    }
    _clearBuffer = len;
  }

  void expand(int nextMax) {
    if(logon) {
      print("(nextMax - _clearedBuffer) == (${nextMax - _clearBuffer}=${nextMax} - ${_clearBuffer};)");
    }
    nextMax = nextMax - _clearBuffer;
    if (_buffer8.length >= nextMax) {
      _length = nextMax;
      return;
    }
    data.Uint8List next = new data.Uint8List(nextMax);
    for (int i = 0; i < _buffer8.length; i++) {
      next[i] = _buffer8[i];
    }
    _buffer8 = null;
    _buffer8 = next;
    _length = _buffer8.length;
  }

  int get length => _length + _clearBuffer;
}
