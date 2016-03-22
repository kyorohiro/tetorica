import 'package:tetorica/cipher/bigint.dart';
import 'package:test/test.dart' as test;

main() {
  test.group("bigint", () {
    test.test("[+]", () {
      {
        BigInt v1 = new BigInt.fromInt(0xffffffffffffffff, 8);
        BigInt v2 = new BigInt.fromInt(0x3, 8);
        BigInt v3 = new BigInt.fromInt(0x5555555555555555, 8);
        test.expect("${v1~/v2}", "${v3}");
      }
    });

  });
}
