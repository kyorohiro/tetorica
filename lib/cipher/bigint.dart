library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt implements Comparable<BigInt> {
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
      value *= -1;
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

  BigInt operator -() {
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

  void clearZero() {
    for (int i = binary.length - 1; i >= 0; i--) {
      binary[i] = 0;
    }
  }

  BigInt operator *(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt a = this;
    BigInt b = other;
    int minus = (((a.isNegative == true ? 1 : 0) ^ (b.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    if (b.isNegative) {
      b = -b;
    }
    if (a.isNegative) {
      a = -a;
    }

    BigInt result = new BigInt.fromLength(a.lengthPerByte);
    BigInt t = new BigInt.fromLength(this.lengthPerByte);
    for (int i = binary.length - 1, tmp = 0; i >= 0; i--) {
      t.clearZero();
      for (int j = i; j >= 0; j--) {
        tmp = a.binary[j] * b.binary[i] + (tmp >> 8);
        t.binary[j] = tmp & 0xff;
      }
      //print("#[${i}]# ${t}");
      result = result + t;
    }
    if (minus == -1) {
      result.mutableMinusOne();
    }
    return result;
  }

  BigInt operator %(BigInt other) {
    BigInt a = this;
    BigInt b = other;
    if (b.isNegative) {
      b = -b;
    }
    if (a.isNegative) {
      a = -a;
    }
    return (other.isNegative==false?a-(a~/b)*b:-(a-(a~/b)*b));
  }

  BigInt operator ~/(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt a = this;
    BigInt b = new BigInt.fromBytes(other.binary);
    int minus = (((a.isNegative == true ? 1 : 0) ^ (b.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    if (a.isNegative) {
      a = -a;
    }
    if (b.isNegative) {
      b = -b;
    }

    //
    //
    BigInt tmp = new BigInt.fromBytes(b.binary);
    BigInt result = new BigInt.fromInt(1, lengthPerByte);
    BigInt one = new BigInt.fromInt(1, lengthPerByte);
    while (a > (tmp * result)) {
      result += one;
    }
    if (a != (tmp * result)) {
      result -= one;
    }
    if (minus == -1) {
      result.mutableMinusOne();
    }
    return result;
  }

  bool operator <(BigInt other) => this.compareTo(other) < 0;

  bool operator <=(BigInt other) => this.compareTo(other) <= 0;

  bool operator >(BigInt other) => this.compareTo(other) > 0;

  bool operator >=(BigInt other) => this.compareTo(other) >= 0;

  bool operator ==(BigInt other) => this.compareTo(other) == 0;

  int compareTo(BigInt other) {
    BigInt a = this;
    BigInt b = new BigInt.fromBytes(other.binary);
    if (a.isNegative != other.isNegative) {
      return (a.isNegative == false ? 1 : -1);
    }
    if (a.isNegative) {
      a = -a;
    }
    if (b.isNegative) {
      b = -b;
    }

    for (int i = 0, len = binary.length; i < len; i++) {
      if (a.binary[i] != b.binary[i]) {
        return (a.binary[i] > b.binary[i] ? (a.isNegative == false ? 1 : -1) : (a.isNegative == false ? -1 : 1));
      }
    }
    return 0;
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
