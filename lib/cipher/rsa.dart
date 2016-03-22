library rsa;

import 'bigint.dart';

// https://tools.ietf.org/html/rfc3447
// https://tools.ietf.org/html/rfc2313
// (m**e)**d %n = m
//   d private, e n public
class RSA {
  //
  // Compute c = m^e mod n
  //
  compute(BigInt m, BigInt e, BigInt n) {
    BigInt c = new BigInt.fromBigInt(m);
    BigInt counter = new BigInt.fromInt(1, m.lengthPerByte);
  }

  encrypt() {}
}
