part of hetimacore;

class TetBuffer {
  //
  bool logon = false;

  //
  int _clearedBuffer = 0;
  int _length = 0;
  List<int> _buffer8 = null;

  //
  List<int> get rawbuffer8 => _buffer8;
  int get clearedBuffer => _clearedBuffer;
  int get length => _length + _clearedBuffer;

  TetBuffer(int max) {
    _length = max;
    _buffer8 = new data.Uint8List(max);
  }

  TetBuffer.fromList(List<int> buffer) {
    _length = buffer.length;
    _buffer8 = new data.Uint8List.fromList(buffer);
  }

  int operator [](int index) {
    return ((index - _clearedBuffer >= 0)?_buffer8[index - _clearedBuffer]:0);
  }

  void operator []=(int index, int value) {
    if (index  >= _clearedBuffer) {
      _buffer8[index - _clearedBuffer] = value;
    }
  }

  List<int> sublist(int start, int end) {
    data.Uint8List ret = new data.Uint8List(end - start);
    for (int j = 0; j < end - start; j++) {
      ret[j] = this[j + start];
    }
    return ret;
  }


  void clearBuffer(int len, {bool reuse: true}) {
    if (_clearedBuffer >= len) {
      return;
    } else if (length < len) {
      len = length;
    }
    int erace = len - _clearedBuffer;

    if (reuse == false) {
      _buffer8 = _buffer8.sublist(erace);
      _length = _buffer8.length;
    } else {
      for (int i = 0; i + erace < _length; i++) {
        _buffer8[i] = _buffer8[i+erace];
      }
      _length = _length-erace;
    }
    _clearedBuffer = len;
  }

  void expandBuffer(int nextMax) {
    nextMax = nextMax - _clearedBuffer;
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

}
