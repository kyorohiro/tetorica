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
      innerMutableMinusOne();
    }
  }

  BigInt.fromLength(int length) {
    binary = new Uint8List(length);
  }

  BigInt.fromBytes(List<int> value) {
    binary = new Uint8List.fromList(value);
  }

  BigInt add(BigInt other, BigInt result) {
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = binary[i] + other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  BigInt operator +(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }
    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    return add(other, result);
  }

  BigInt operator -() {
    return new BigInt.fromBytes(binary)..innerMutableMinusOne();
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

  void innerMutableMinusOne() {
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = 0 - binary[i] + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
  }

  void innerClearZero() {
    // recreate is more fast then sets zero
    binary = new Uint8List(binary.length);
    //    for (int i = binary.length - 1; i >= 0; i--) {
    //      binary[i] = 0;
    //    }
  }

  BigInt innerMultiplication(BigInt other, BigInt result, BigInt tmpBigInt) {
    int minus = (((this.isNegative == true ? 1 : 0) ^ (other.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    BigInt a = (this.isNegative == true ? -this : this);
    BigInt b = (other.isNegative == true ? -other : other);
    if (a < b) {
      var t = a;
      a = b;
      b = t;
    }
    for (int i = binary.length - 1, ii = 0, tmpValue = 0; i >= 0; i--, ii++) {
      tmpBigInt.innerClearZero();
      for (int j = binary.length - 1; j >= 0 && j - ii >= 0; j--) {
        tmpValue = a.binary[j] * b.binary[i] + (tmpValue >> 8);
        tmpBigInt.binary[j - ii] = tmpValue & 0xff;
      }
      result.add(tmpBigInt, result);
    }
    if (minus == -1) {
      result.innerMutableMinusOne();
    }
    return result;
  }

  BigInt operator *(BigInt other) {
    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    BigInt t = new BigInt.fromLength(this.lengthPerByte);
    innerMultiplication(other, result, t);
    return result;
  }

  BigInt operator %(BigInt other) {
    BigInt a = (this.isNegative == true ? -this : this);
    BigInt b = (other.isNegative == true ? -other : other);
    return (other.isNegative == false ? a - (a ~/ b) * b : -(a - (a ~/ b) * b));
  }

  BigInt operator ~/(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }
    int minus = (((this.isNegative == true ? 1 : 0) ^ (other.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    BigInt a = (this.isNegative == false ? this : -this);
    BigInt b = (other.isNegative == false ? new BigInt.fromBytes(other.binary) : -(new BigInt.fromBytes(other.binary)));
    BigInt r = new BigInt.fromLength(lengthPerByte);

    BigInt multipleTmp = new BigInt.fromLength(lengthPerByte);
    BigInt multipleTmpResult = new BigInt.fromLength(lengthPerByte);

    //
    // todo i= 2
    for (int i = 2, len = binary.length; i < len; i++) {
      r.binary[i] = 0x01;
      multipleTmpResult.innerClearZero();
      if (a < b.innerMultiplication(r, multipleTmpResult, multipleTmp)) {
        r.binary[i] = 0;
        continue;
      }
      multipleTmpResult.innerClearZero();
      r.binary[i] = (i == 0 ? 0x7f : 0xff);
      if (a >= b.innerMultiplication(r, multipleTmpResult, multipleTmp)) {
        //print("BBB ${a} ${multipleTmpResult}::: ${b} ${r}");
        continue;
      }

      r.binary[i] = 0x01;
      int pe = (i == 0 ? 0x7f : 0xff);
      int ps = 1;
      for (; ps != pe;) {
        var tt = (pe - ps) ~/ 2 + ps;
        if (ps + 1 == pe) {
          r.binary[i] = ps;
          break;
        }
        r.binary[i] = tt;
        //
        multipleTmpResult.innerClearZero();
        var t = b.innerMultiplication(r, multipleTmpResult, multipleTmp);
        int c = a.compareTo(t);
        if (c < 0) {
          pe = tt;
        } else if (c == 0) {
          break;
        } else {
          ps = tt;
        }
      }
    }

    if (minus == -1) {
      r.innerMutableMinusOne();
    }
    return r;
  }

  bool operator <(BigInt other) => this.compareTo(other) < 0;

  bool operator <=(BigInt other) => this.compareTo(other) <= 0;

  bool operator >(BigInt other) => this.compareTo(other) > 0;

  bool operator >=(BigInt other) => this.compareTo(other) >= 0;

  bool operator ==(BigInt other) => this.compareTo(other) == 0;

  int compareTo(BigInt other) {
    if (this.isNegative != other.isNegative) {
      return (this.isNegative == false ? 1 : -1);
    }

    BigInt a = (this.isNegative == true ? -this : this);
    BigInt b = (other.isNegative == true ? -other : other);

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
