library hex;

import 'dart:typed_data';
import 'dart:convert' as conv;

class Hex {
  static const List<int> hexBytes = const [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66];

  static List<int> decodeWithNew(String value, {bool have0x:true}) {
    List<int> source = conv.ASCII.encode(value);
    int bufferLen = (source.length-2)~/2 + source.length%2;
    //BBuffer buffer = new BBuffer(0, bufferLen);
    Uint8List buffer = new Uint8List(bufferLen);
    decode(source, 0, source.length, buffer, 0, bufferLen, have0x: have0x);
    return buffer;
  }

  static String encodeWithNew(List<int> value, {bool have0x:true}) {
    int bufferLen = 2 + value.length * 2;
    Uint8List buffer = new Uint8List(bufferLen);
    encode(value, 0, value.length, buffer, 0, bufferLen, have0x: have0x);
    return conv.ASCII.decode(buffer);
  }

  static int decode(List<int> source, int sourceIndex, int sourceLength, List<int> result, int resultIndex, int resultLength, {bool have0x:true}) {
    if (have0x == true && sourceLength < 2) {
      throw {};
    }
    int si = (have0x==true?sourceIndex + 2:sourceIndex);
    int len = sourceLength;
    int ri = resultIndex;
    List<int> buffer = result;

    int v1;
    int v2;
    int v3;
    for (int end = len - len % 2; si < end; si += 2) {
      v1 = source[si];
      v2 = source[si + 1];
      if (0x41 <= v1 && v1 <= 0x46) {
        v3 = (v1 - 0x37);
      } else if (0x61 <= v1 && v1 <= 0x66) {
        v3 = v1 - 0x57;
      } else if (0x30 <= v1 && v1 <= 0x39) {
        v3 = v1 - 0x30;
      } else {
        throw {};
      }
      if (0x41 <= v2 && v2 <= 0x46) {
        buffer[ri++] = (v3 << 4) | (v2 - 0x37);
      } else if (0x61 <= v2 && v2 <= 0x66) {
        buffer[ri++] = (v3 << 4) | (v2 - 0x57);
      } else if (0x30 <= v2 && v2 <= 0x39) {
        buffer[ri++] = (v3 << 4) | (v2 - 0x30);
      } else {
        throw {};
      }
    }
    if (len % 2 == 1) {
      int v;
      if (0x41 <= v && v <= 0x46) {
        buffer[ri++] = (v - 0x37);
      } else if (0x61 <= v && v <= 0x66) {
        buffer[ri++] = v - 0x57;
      } else if (0x30 <= v && v <= 0x39) {
        buffer[ri++] = v - 0x30;
      } else {
        throw {};
      }
    }
    return ri - resultIndex;
  }

  static int encode(List<int> source, int sourceIndex, int sourceLength, List<int> result, int resultIndex, int resultLength,{bool have0x:true}) {
    int si = sourceIndex;
    int len = sourceLength;
    int ri = resultIndex;
    List<int> buffer = result;

    int v;
    if(have0x) {
      buffer[ri++] = 0x30;
      buffer[ri++] = 0x78;
    }
    for (; si < len; si++) {
      v = source[si];
      buffer[ri++] = hexBytes[(v >> 4) & 0xf];
      buffer[ri++] = hexBytes[v & 0xf];
    }

    return ri - resultIndex;
  }
}
