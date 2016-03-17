library hex;

import 'cipher.dart';

class Hex {
  static const List<int> hexBytes = const [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66];

  static List<int> decode(List<int> source, int sourceIndex, int sourceLength, BBuffer result) {
    int si = sourceIndex + 2;
    int len = sourceLength;
    int ri = result.index;
    List<int> buffer = result.buffer;

    if (sourceLength < 2) {
      throw {};
    }

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
    result.length = ri;
    return buffer;
  }

  static List<int> encode(List<int> source, int sourceIndex, int sourceLength, BBuffer result) {
    int si = sourceIndex;
    int len = sourceLength;
    int ri = result.index;
    List<int> buffer = result.buffer;

    int v;
    buffer[ri++] = 0x30;
    buffer[ri++] = 0x78;
    for (; si < len; si++) {
      v = source[si];
      buffer[ri++] = hexBytes[(v >> 4) & 0xf];
      buffer[ri++] = hexBytes[v & 0xf];
    }
    result.length = result.index + ri;
    return buffer;
  }
}
