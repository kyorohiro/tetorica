library cipher;

import 'dart:typed_data';

class BBuffer {
  List<int> buffer;
  int index;
  int length;
  BBuffer(this.index, this.length) {
    this.buffer = new Uint8List(length);
  }

  updateBuffer() {
    List<int> nextBuffer = new Uint8List(this.buffer.length * 2);
    for (int i = 0, len = this.buffer.length; i < len; i++) {
      nextBuffer[i] = this.buffer[i];
    }
    this.buffer = nextBuffer;
  }
}
