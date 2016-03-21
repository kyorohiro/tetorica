library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt {
  int get lengthPerByte => binary.length;
  List<int> binary;

  bool get isNegative => (binary[0] & 0x80) != 0;

  BigInt.fromInt(int value, int length) {
    binary = new Uint8List((length > 8) ? length : 8);
    int _len = binary.length;
    if (value >= 0) {
      binary[_len - 8] = (value >> 56 & 0xff);
      binary[_len - 7] = (value >> 48 & 0xff);
      binary[_len - 6] = (value >> 40 & 0xff);
      binary[_len - 5] = (value >> 32 & 0xff);
      binary[_len - 4] = (value >> 24 & 0xff);
      binary[_len - 3] = (value >> 16 & 0xff);
      binary[_len - 2] = (value >> 8 & 0xff);
      binary[_len - 1] = (value >> 0 & 0xff);
    } else {
      value *=-1;
      binary[_len - 8] = (value >> 56 & 0xff);
      binary[_len - 7] = (value >> 48 & 0xff);
      binary[_len - 6] = (value >> 40 & 0xff);
      binary[_len - 5] = (value >> 32 & 0xff);
      binary[_len - 4] = (value >> 24 & 0xff);
      binary[_len - 3] = (value >> 16 & 0xff);
      binary[_len - 2] = (value >> 8 & 0xff);
      binary[_len - 1] = (value >> 0 & 0xff);
      mutableMinusOne();
    }
  }

  BigInt.fromLength(int length) {
    binary = new Uint8List(length);
  }

  BigInt.fromBytes(List<int> value) {
    binary = new Uint8List.fromList(value);
  }

  BigInt operator +(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = binary[i] + other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  BigInt operator -(){
    return new BigInt.fromBytes(binary)..mutableMinusOne();
  }

  BigInt operator -(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = binary[i] - other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  void mutableMinusOne() {
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = 0 - binary[i] + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
  }

  BigInt operator *(BigInt other) {
    BigInt a = this;
    BigInt b = other;

    if (a.lengthPerByte != b.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    int c = (((a.isNegative==true?1:0) ^ (b.isNegative==true?1:0))==1?-1:1);
    if(b.isNegative) {
      b = -other;
    }
    if(a.isNegative) {
      a = -other;
    }

    BigInt result = new BigInt.fromLength(a.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = a.binary[i] * b.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    if(c==-1) {
      result.mutableMinusOne();
    }
    return result;
  }

  int get hashCode {
    int h = 0;
    for (int i = 0, len = binary.length; i < len; i++) {
      h = h * 31 + binary[i].hashCode;
    }
    return h;
  }

  @override
  String toString() {
    return Hex.encodeWithNew(binary);
  }
//  BigInt operator -() => new BigInt(value, isNegative);

}
