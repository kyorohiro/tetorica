library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt implements Comparable<BigInt> {
  int get lengthPerByte => binary.length;

  int get sizePerByte {
    int i = 0;
    int len = binary.length;
    for (; i < len; i++) {
      if (binary[i] != 0) {
        break;
      }
    }
    return len - i;
  }

  List<int> binary;

  bool get isNegative => (binary[0] & 0x80) != 0;

  //
  // ~/ need (length +1)
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

  BigInt.fromBytes(List<int> value, int length) {
    if (value.length == length) {
      binary = new Uint8List.fromList(value);
    } else {
      binary = new Uint8List(length);
      for (int i = 0, s = value.length - length; i < length; i++, s++) {
        if (s >= 0) {
          binary[i] = value[s];
        } else {
          binary[i] = 0;
        }
      }
    }
  }

  BigInt.fromBigInt(BigInt value) {
    binary = new Uint8List.fromList(value.binary);
  }

  BigInt innerAdd(BigInt other, BigInt result) {
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
    return innerAdd(other, result);
  }

  BigInt operator -() {
    return new BigInt.fromBytes(binary, binary.length)..innerMutableMinusOne();
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
    //for (int i = binary.length - 1; i >= 0; i--) {
    //      binary[i] = 0;
    //}
  }

  void innerIncrement() {
    int tmp = 1;
    for (int i = binary.length - 1, start = binary.length - 1; i >= 0 && tmp != 0; i--) {
      tmp = binary[i] + (i == start ? 1 : 0) + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
  }

  void innerDecrement() {
    int tmp = 1;
    for (int i = binary.length - 1, start = binary.length - 1; i >= 0 && tmp != 0; i--) {
      tmp = binary[i] + (i == start ? -1 : 0) + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
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
    for (int i = binary.length - 1, ii = 0, tmpValue = 0; i >= 0; i--, ii++, tmpValue = 0) {
      if (b.binary[i] == 0) {
        continue;
      }
      tmpBigInt.innerClearZero();
      for (int j = binary.length - 1; j >= 0 && j - ii >= 0; j--) {
        tmpValue = a.binary[j] * b.binary[i] + (tmpValue >> 8);
        tmpBigInt.binary[j - ii] = tmpValue & 0xff;
      }
      result.innerAdd(tmpBigInt, result);
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
    int minus = (((this.isNegative == true ? 1 : 0) ^ (other.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    BigInt a = (this.isNegative == false ? this : -this);
    BigInt b = (other.isNegative == false ? new BigInt.fromBytes(other.binary, other.lengthPerByte) : -(new BigInt.fromBytes(other.binary, other.lengthPerByte)));
    BigInt r = new BigInt.fromLength(lengthPerByte);

    int sizeA = a.sizePerByte;
    int sizeB = b.sizePerByte;
    if (sizeA < sizeB) {
      return r;
    }

    //
    //
    int bitSize = (sizeA - sizeB - 2) * 8;
    int bitPosition = 0;
    if (bitSize < 0) {
      bitSize = 0;
    }
    for (int i = 0; i < bitSize; i++) {
      b.innerLeftShift();
    }
    while (b < a) {
      b.innerLeftShift();
      bitSize++;
    }
    //
    //
    bitPosition = 8 - (bitSize % 8) - 1;
    int rSize = (bitSize ~/ 8) + 1;

    do {
      if (b <= a) {
        a -= b;
        r.binary[(lengthPerByte - rSize) + (bitPosition ~/ 8)] |= (0x80 >> (bitPosition % 8));
      }
      if (bitSize != 0) {
        b.innerRightShift();
      }
      bitPosition++;
    } while (bitSize-- != 0);

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

//    int sizeA = a.sizePerByte;
//    int sizeB = b.sizePerByte;
//    if(sizeA != sizeB) {
//      return (sizeA>sizeB?1:-1);
//    }
//for (int len = binary.length, i = (len-(1+sizeA)>0?len-(1+sizeA):0); i < len; i++) {

    for (int len = binary.length, i = 0; i < len; i++) {
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

//
// http://www.amazon.com/Implementing-SSL-TLS-Using-Cryptography/dp/0470920416
  BigInt exponentiate(BigInt exp) {
    int i = exp.sizePerByte;
    int n = exp.lengthPerByte;
    int mask = 0;

    BigInt tmp1 = new BigInt.fromBigInt(this);
    BigInt ret = new BigInt.fromInt(1, this.lengthPerByte);

    int j = 0;
    do {
      i--;
      j++;
      for (mask = 0x01; mask != 0; mask = ((mask << 1) & 0xff)) {
        if (exp.binary[n - j] & mask != 0) {
          ret = ret * tmp1;
        } else {}
        tmp1 = tmp1 * tmp1;
      }
    } while (i != 0);

    return ret;
  }

  BigInt exponentiateWithMod(BigInt exp, BigInt m) {
    int i = exp.sizePerByte;
    int n = exp.lengthPerByte;
    int mask = 0;

    BigInt tmp1 = new BigInt.fromBigInt(this);
    BigInt ret = new BigInt.fromInt(1, this.lengthPerByte);

    int j = 0;
    do {
      i--;
      j++;
      for (mask = 0x01; mask != 0; mask = ((mask << 1) & 0xff)) {
        if (exp.binary[n - j] & mask != 0) {
          ret = ret * tmp1;
          ret = ret % m;
        }
        tmp1 = tmp1 * tmp1;
        tmp1 = tmp1 % m;
      }
    } while (i != 0);

    return ret;
  }

  void innerLeftShift() {
    int oldCarry = 0, carry = 0;
    int end = this.sizePerByte + 1;
    if (end > this.lengthPerByte) {
      end--;
    }
    for (int i = this.lengthPerByte - 1, j = 0; j < end; i--, j++) {
      oldCarry = carry;
      carry = ((this.binary[i] & 0x80) == 0x80 ? 1 : 0);
      this.binary[i] = (this.binary[i] << 1 | oldCarry);
    }
    //
    //if(carry == 1) {
    // overflow!!
    //}
    //
  }

  void innerRightShift() {
    int oldCarry = 0, carry = 0;
    int i = lengthPerByte - sizePerByte;
    for (int end = lengthPerByte; i < end; i++) {
      oldCarry = carry;
      carry = ((this.binary[i] & 0x01) == 0x01 ? 0x80 : 0);
      this.binary[i] = (this.binary[i] >> 1 | oldCarry);
    }
    //
    //if(carry == 1) {
    // overflow!!
    //}
    //
  }
}
