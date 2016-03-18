library base64;

class Base64 {
  static const List<int> base64Bytes = const [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47];
  static const List<int> unbase64Bytes = const [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, -1];
  static const int equalByte = 61;

  static int encode(
    List<int> input, int sourceIndex, int sourceLength,
    List<int> result, int resultIndex, int resultLength) {
    int len = sourceLength - sourceIndex, end = len - (len % 3);
    List<int> buffer = result;

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
      //print("#-A#");
        buffer[ri++] = base64Bytes[0x3f & (input[si] >> 2)];
        buffer[ri++] = base64Bytes[0x3f & ((input[si] & 0x03) << 4)];
        break;
      case 2:
        buffer[ri++] = base64Bytes[0x3f & (input[si] >> 2)];
        buffer[ri++] = base64Bytes[0x3f & ((input[si] & 0x03) << 4) | ((input[si + 1] >> 4) & 0x0F)];
        buffer[ri++] = base64Bytes[0x3f & ((input[si + 1] << 2) & 0x3C)];
//        print("#-B# 0:${input[si]}, 1:${input[si + 1]} __ ${buffer[ri-1]} ${buffer[ri-2]} ${buffer[ri-3]}");
        break;
      default:
    }

    int l = ((ri - resultIndex) % 4);
    if (l != 0) {
      l = 4 - l;
      for (int j = 0; j < l; j++) {
        buffer[ri++] = equalByte;
      }
    }
    return ri - resultIndex;
  }

  static int decode(
    List<int> input, int sourceIndex, int sourceLength,
    List<int> result, int resultIndex, int resultLength) {
    List<int> buffer = result;
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
    if (equalByte == input[sourceIndex + sourceLength - 3]) {
      ri -= 2;
      //print("##--A");
    } else if (equalByte == input[sourceIndex + sourceLength - 2]) {
      ri -= 2;
      //print("##--B");
    }  else if (equalByte == input[sourceIndex + sourceLength - 1]) {
      ri -= 1;
      //print("##--C");
    } else {
      //print("##--D");
    }

    return ri - resultIndex;
  }
}
