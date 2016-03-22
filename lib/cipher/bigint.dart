library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt implements Comparable<BigInt> {
  int get lengthPerByte => binary.length;

  int get sizePerByte {
    int i=0;
    int len=binary.length;
    for(;i<len;i++) {
      if(binary[i] != 0) {
        break;
      }
    }
    return len-i;
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

  BigInt.fromBytes(List<int> value) {
    binary = new Uint8List.fromList(value);
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
    //for (int i = binary.length - 1; i >= 0; i--) {
    //      binary[i] = 0;
    //}
  }

  void innerIncrement() {
    int tmp = 1;
    for (int i = binary.length - 1,start=binary.length - 1; i >= 0&&tmp!=0; i--) {
      tmp = binary[i] + (i==start?1:0) + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
  }

  void innerDecrement() {
    int tmp = 1;
    for (int i = binary.length - 1,start=binary.length - 1; i >= 0&&tmp!=0; i--) {
      tmp = binary[i] + (i==start?-1:0) + (tmp >> 8);
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
      if(b.binary[i] == 0){
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
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }
    int minus = (((this.isNegative == true ? 1 : 0) ^ (other.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    BigInt a = (this.isNegative == false ? this : -this);
    BigInt b = (other.isNegative == false ? new BigInt.fromBytes(other.binary) : -(new BigInt.fromBytes(other.binary)));
    BigInt r = new BigInt.fromLength(lengthPerByte);


    //
    for (int i = 1, len = binary.length; i < len; i++) {
      r.binary[i] = 0x01;
      if (a < b*r) {
        r.binary[i] = 0;
        continue;
      }
      r.binary[i] = (i == 0 ? 0x7f : 0xff);
      if (a >= b*r) {
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
        var t = b*r;//
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

//
// http://www.amazon.com/Implementing-SSL-TLS-Using-Cryptography/dp/0470920416
  BigInt exponentiat(BigInt exp){
    int i= exp.sizePerByte;
    int n= exp.lengthPerByte;
    int mask = 0;

    BigInt tmp1 = new BigInt.fromBigInt(this);
    BigInt ret = new BigInt.fromInt(1, this.lengthPerByte);

    //
    do {
      i--;
      for(mask=0x01;mask!= 0;mask=(mask<<1)&0xffffffff) {
        print(">> ${mask}");
        if(exp.binary[n-i-1]&mask != 0) {
          ret = ret*tmp1;
        }
        tmp1 = tmp1 * tmp1;
      }
    } while(i != 0);

    return ret;
  }
}
