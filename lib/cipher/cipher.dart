library cipher;

import 'dart:typed_data';

class BBuffer {
  List<int> buffer;
  int position;
  int _capacity;
  int length = 0;

  BBuffer(this.position, this._capacity, {List<int> this.buffer: null}) {
    this.buffer = new Uint8List(this._capacity);
    ByteBuffer b;
    ByteData d = new ByteData(1);
  }

  BBuffer.fromBuffer(this.position, List<int> this.buffer) {
    this._capacity = this.buffer.length;
  }

  BBuffer mapping(int nextPosition) {
    return new BBuffer.fromBuffer(nextPosition, this.buffer);
  }

  updateBuffer() {
    List<int> nextBuffer = new Uint8List(this.buffer.length * 2);
    for (int i = 0, len = this.buffer.length; i < len; i++) {
      nextBuffer[i] = this.buffer[i];
    }
    this.buffer = nextBuffer;
  }
}
