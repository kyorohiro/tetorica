library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
//
// bignum
// todo divide fun is slow now.
//
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

    b.innerLeftShift(move: bitSize);
    while (b < a) {
      b.innerLeftShift();
      bitSize++;
    }
    //
    //
    bitPosition = 8 - (bitSize % 8) - 1;
    int rSize = (bitSize ~/ 8) + 1;

    int bRightShiftNum = 0;
//    BigInt tmp = new BigInt.fromLength(other.lengthPerByte);
    do {

     if (b <= a) {
//    print("${bRightShiftNum} ${b} ${a}");

  //if(b.compareWithRightShift(a, bRightShiftNum, result: tmp)<=0) {
//        a -= tmp;
//        tmp =new BigInt.fromLength(other.lengthPerByte);
        a -=b;
        r.binary[(lengthPerByte - rSize) + (bitPosition ~/ 8)] |= (0x80 >> (bitPosition % 8));
      }
      //
      // todo
      if (bitSize != 0) {
//        bRightShiftNum++;
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

  void innerLeftShift({int move: 1}) {
    int moveByte = move ~/ 8;
    int moveBit = move % 8;
    //print("${moveBit} ${moveByte} ${this}");
    if (move != 1) {
      int j = 0;
      for (j = 0; j < (lengthPerByte - moveByte); j++) {
        //    print("-A- ${j} ${j-moveByte}");
        this.binary[j] = this.binary[j + moveByte];
      }
      for (int j = lengthPerByte - 1; j >= (lengthPerByte - moveByte); j--) {
        //  print("-B- ${j}");
        this.binary[j] = 0;
      }
    }

    for (int j = 0; j < moveBit; j++) {
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
  }

  void innerRightShift() {
    int oldCarry = 0, carry = 0;
    int i = lengthPerByte - sizePerByte;
    for (int end = lengthPerByte, tmp = 0; i < end; i++) {
//      if(carry == 0 && this.binary[i]==0) {
//        continue;
//      }
      tmp = this.binary[i];
      oldCarry = carry;
      carry = ((tmp & 0x01) == 0x01 ? 0x80 : 0);
      this.binary[i] = (tmp >> 1 | oldCarry);
    }
    //
    //if(carry == 1) {
    // overflow!!
    //}
    //
  }

  int compareWithRightShift(BigInt other, int move) {
    if (this.isNegative != other.isNegative) {
      return (this.isNegative == false ? 1 : -1);
    }

    BigInt a = (this.isNegative == true ? -this : this);
    BigInt b = (other.isNegative == true ? -other : other);

    int moveByte = move ~/ 8;
    int moveBit = move % 8;

    int v1 = 0;
    int v2 = 0;
    int mask1 = 0x00;
    int mask2 = 0xff;
    switch (moveBit) {
      case 0:
        mask1 = 0x00;
        mask2 = 0xff;
        break;
      case 1:
        mask1 = 0x01;
        mask2 = 0xFE;
        break;
      case 2:
        mask1 = 0x03;
        mask2 = 0xFC;
        break;
      case 3:
        mask1 = 0x07;
        mask2 = 0xF8;
        break;
      case 4:
        mask1 = 0x0F;
        mask2 = 0xF0;
        break;
      case 5:
        mask1 = 0x1F;
        mask2 = 0xE0;
        break;
      case 6:
        mask1 = 0x3F;
        mask2 = 0xC0;
        break;
      case 7:
        mask1 = 0x7F;
        mask2 = 0x80;
        break;
    }
  //  print("####### ${a} ${b}");
  //  print("####### ${mask1} ${mask2} ${moveByte} ${moveBit}");
    int v1a = 0;
    int v1b = 0;
    int ret = 0;
    for (int len = binary.length, i = 0; i < len; i++) {
      if(i-1-moveByte < 0){
        v1a = 0;
      } else {
        v1a = (a.binary[i-1-moveByte]&mask1)<<(8-moveBit);
      }
      if(i-moveByte < 0) {
        v1b = 0;
      } else {
        v1b = ((a.binary[i-moveByte] &mask2)>>moveBit);
      }
      v1 = (v1a|v1b);
      v2 = b.binary[i];

      //  print("${i}:${v1} ${v2}");
      if (v1 != v2) {
        ret = (v1 > v2 ? (a.isNegative == false ? 1 : -1) : (a.isNegative == false ? -1 : 1));
        return ret;
      }
    }
    return 0;
  }

/*
  BigInt innerRightShifts(int move) {
    BigInt a = (this.isNegative == true ? -this : this);
    BigInt r = new BigInt.fromLength(this.lengthPerByte);

    int moveByte = move ~/ 8;
    int moveBit = move % 8;

    int v1 = 0;
    int v2 = 0;
    int mask1 = 0x00;
    int mask2 = 0xff;
    switch (moveBit) {
      case 0:
        mask1 = 0x00;
        mask2 = 0xff;
        break;
      case 1:
        mask1 = 0x01;
        mask2 = 0xFE;
        break;
      case 2:
        mask1 = 0x03;
        mask2 = 0xFC;
        break;
      case 3:
        mask1 = 0x07;
        mask2 = 0xF8;
        break;
      case 4:
        mask1 = 0x0F;
        mask2 = 0xF0;
        break;
      case 5:
        mask1 = 0x1F;
        mask2 = 0xE0;
        break;
      case 6:
        mask1 = 0x3F;
        mask2 = 0xC0;
        break;
      case 7:
        mask1 = 0x7F;
        mask2 = 0x80;
        break;
    }
  //  print("####### ${a} ${b}");
  //  print("####### ${mask1} ${mask2} ${moveByte} ${moveBit}");
    int v1a = 0;
    int v1b = 0;
    for (int i = binary.length-1; i >=0; i--) {
      if(i-1-moveByte < 0){
        v1a = 0;
      } else {
        v1a = (a.binary[i-1-moveByte]&mask1)<<(8-moveBit);
      }
      if(i-moveByte < 0) {
        v1b = 0;
      } else {
        v1b = ((a.binary[i-moveByte] &mask2)>>moveBit);
      }
      v1 = (v1a|v1b);
      r.binary[i] = v1;
    }
    return r;
  }
  */
}
