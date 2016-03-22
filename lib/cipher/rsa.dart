library rsa;

import 'bigint.dart';

// https://tools.ietf.org/html/rfc3447
// https://tools.ietf.org/html/rfc2313
// (m**e)**d %n = m
//   d private, e n public
class RSA {

  static BigInt exp(BigInt m, BigInt e) {
    BigInt c = new BigInt.fromBigInt(m);
    BigInt counter = new BigInt.fromInt(1, m.lengthPerByte);
    while(counter < e) {
      c = c*m;
      counter.innerIncrement();
    }
    return c;
  }
  //
  // Compute c = m^e mod n
  //
  static BigInt compute(BigInt m, BigInt e, BigInt n) {
//    BigInt c = new BigInt.fromBigInt(m);
//    BigInt counter = new BigInt.fromInt(1, m.lengthPerByte);
//    while(counter < e) {
//      c = c*m;
//      counter.innerIncrement();
//    }
    BigInt c = m.exponentiate(e);
//    print("##### ${c} #####");
    c = c % n;
    return c;
  }

  //
  static int computeA(int m, int e, int n) {
    int c = m;
    int counter = 1;

    while(counter < e) {
      c = c*m;
      counter++;
    }
    c = c % n;
    return c;
  }
  encrypt() {}
}
