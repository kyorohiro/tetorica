import 'package:tetorica/cipher/bigint.dart';
import 'package:tetorica/cipher/rsa.dart';
import 'package:test/test.dart' as test;

main() {
  test.group("bigint", () {
    test.test("[+]", () {
      {
        int bufferSize = 20*620;
        BigInt e = new BigInt.fromInt(0x4f, bufferSize);
        BigInt d = new BigInt.fromInt(0x3fb, bufferSize);
        BigInt n = new BigInt.fromInt(0xd09, bufferSize);
        BigInt m1 = new BigInt.fromInt(0x2b0, bufferSize);

        // encrypt
        BigInt c = RSA.compute(m1, e, n);
        test.expect("${c}","${new BigInt.fromInt(1570,bufferSize)}");

        // decrypt
        BigInt m2 = RSA.compute(c, d, n);
        test.expect("${m2}","${new BigInt.fromInt(688,bufferSize)}");
      }
    });

  });
}
