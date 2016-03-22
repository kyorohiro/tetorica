import 'package:tetorica/cipher/bigint.dart';
import 'package:tetorica/cipher/rsa.dart';
import 'package:test/test.dart' as test;

main() {
  test.group("bigint", () {
    test.test("[+]", () {
      {
        BigInt e = new BigInt.fromInt(0x4f, 10*620);
        BigInt d = new BigInt.fromInt(0x3fb, 10*620);
        BigInt n = new BigInt.fromInt(0xd09, 10*620);
        BigInt m1 = new BigInt.fromInt(0x2b0, 10*620);
        //print("\n[=A=]\ne=${e}\nd=${d}\nn=${n}\n$m1={m1}\n===\n");
        BigInt c = RSA.compute(m1, e, n);
      //  int cc = RSA.computeA(0x2b0, 0x4f, 0xd09);
      //  print("\n[=Ba1=]\nc=${c}\n===\n");
        test.expect("${c}","${new BigInt.fromInt(1570,10*620)}");
        //print("\n[=Ba2=]\nc=${cc}\n===\n");

        BigInt m2 = RSA.compute(c, d, n);
        //int mm2 = RSA.computeA(cc, 0x3fb, 0xd09);
        test.expect("${m1}","${new BigInt.fromInt(688,10*620)}");
        //print("\n[=Bb=]\nc=${m2}\n===\n");
        //print("\n[=Bb=]\nc=${mm2}\n===\n");

        //print("\n[-C-]\nm1=${m1}\nc=${c}\nm2=${m2}\n---\n");
      }
    });

  });
}
