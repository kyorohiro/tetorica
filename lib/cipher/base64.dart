library base64;

import 'dart:convert';
import 'dart:typed_data';

class Base64 {
  static final String base64Text = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  static final List<int> base64Bytes = ASCII.encode(base64Text);
  static final List<int> unbase64Bytes = const [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, -1];
  static final int equalByte = ASCII.encode("=")[0];

  static List<int> encode(List<int> input, int sourceIndex, Result result) {
    int len = input.length - sourceIndex, end = len - (len % 3);
    int resultIndex = result.index;
    List<int> buffer = result.buffer;

    int si = sourceIndex;
    int ri = resultIndex;

    for (end += si; si < end; si += 3) {
      buffer[ri++] = base64Bytes[0x3f & (input[si] >> 2)];
      buffer[ri++] = base64Bytes[0x3f & ((input[si] & 0x03) << 4) | ((input[si + 1] >> 4) & 0x0F)];
      buffer[ri++] = base64Bytes[0x3f & (((input[si + 1] << 2) & 0x3C) | (input[si + 2] >> 6) & 0x03)];
      buffer[ri++] = base64Bytes[0x3f & input[si + 2]];
    }
    switch (len % 3) {
      case 1:
        buffer[ri++] = base64Bytes[0x3f & (input[si] >> 2)];
        buffer[ri++] = base64Bytes[0x3f & ((input[si] & 0x03) << 4)];
        break;
      case 2:
        buffer[ri++] = base64Bytes[0x3f & (input[si] >> 2)];
        buffer[ri++] = base64Bytes[0x3f & ((input[si] & 0x03) << 4)];
        buffer[ri++] = base64Bytes[0x3f & (((input[si + 1] << 2) & 0x3C) | (input[si + 2] >> 6) & 0x03)];
        break;
      default:
    }
    for (int j = 0, len = ri % 4; j < len; j++) {
      buffer[ri + j] = equalByte;
    }
    result.length = ri - result.index;
    return buffer;
  }

  static List<int> decode(List<int> input, int sourceIndex, int sourceLength, Result result) {
    int resultIndex = result.index;
    List<int> buffer = result.buffer;
    int si = sourceIndex;
    int ri = resultIndex;
    int v1, v2, v3, v4 = 0;
    for (int end = sourceIndex + sourceLength; si < end; si += 4) {
      v1 = unbase64Bytes[input[si]];
      v2 = unbase64Bytes[input[si + 1]];
      v3 = unbase64Bytes[input[si + 2]];
      v4 = unbase64Bytes[input[si + 3]];
      buffer[ri++] = ((v1 << 2) & 0xfc) | ((v2 >> 4) & 0x03);
      buffer[ri++] = ((v2 << 4) & 0xf0) | ((v3 >> 2) & 0xf);
      buffer[ri++] = ((v3 << 6) & 0xf0) | (v4 & 0x3f);
    }
    result.length = ri - result.index;
    return buffer;
  }

}

class Result {
  List<int> buffer;
  int index;
  int length;
  Result(this.index, this.length) {
    this.index = 0;
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
