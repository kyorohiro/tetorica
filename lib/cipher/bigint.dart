library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt {
  int _len = 0;
  int get lengthPerByte => _len;
  List<int> binary;

  BigInt.fromInt(int value, int length) {
    binary = new Uint8List(length);
    _len = binary.length;
    binary[_len - 8] = (value >> 56 & 0xff);
    binary[_len - 7] = (value >> 48 & 0xff);
    binary[_len - 6] = (value >> 40 & 0xff);
    binary[_len - 5] = (value >> 32 & 0xff);
    binary[_len - 4] = (value >> 24 & 0xff);
    binary[_len - 3] = (value >> 16 & 0xff);
    binary[_len - 2] = (value >> 8 & 0xff);
    binary[_len - 1] = (value >> 0 & 0xff);
  }

  BigInt.fromLength(int length) {
    binary = new Uint8List(length);
    _len = binary.length;
  }

  BigInt operator +(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length; i >= 0; i--) {
      tmp = binary[i] + other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  @override
  String toString() {
    return Hex.encodeWithNew(binary);
  }
//  BigInt operator -() => new BigInt(value, isNegative);

}
