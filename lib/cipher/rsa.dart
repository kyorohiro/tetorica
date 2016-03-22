library rsa;

import 'bigint.dart';

// https://tools.ietf.org/html/rfc3447
// https://tools.ietf.org/html/rfc2313
// (m**e)**d %n = m
//   d private, e n public
class RSA {

  //
  // Compute c = m^e mod n
  // 0 is slow. but low memory
  // 1 is fast. but high memory
  static BigInt compute(BigInt m, BigInt e, BigInt n, {int mode: 0}) {
    if (mode == 1) {
      BigInt c = m.exponentiate(e);
      print("##># ${c.sizePerByte}");
      c = c % n;
      return c;
    } else {
      var r =  m.exponentiateWithMod(e, n);
      print("##># ${r.sizePerByte}");
      return r;
    }
  }

  encrypt() {
    
  }
}
