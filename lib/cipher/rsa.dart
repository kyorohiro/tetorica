library rsa;

import 'bigint.dart';

// https://tools.ietf.org/html/rfc3447
// https://tools.ietf.org/html/rfc2313
// (m**e)**d %n = m
//   d private, e n public
//
// RSA 512(64byte) 1024(128byte) 2048(256byte)
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
/**
 ./a.out -e 0xbc
 --> 0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d
 ./a.out -d 0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d
--> bc
 */
