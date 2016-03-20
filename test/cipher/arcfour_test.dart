import 'package:tetorica/cipher/arcfour.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;

main() {
  test.group("arcfour", () {
    test.test("operateA", () {
      List<int> key = Hex.decodeWithNew("0xABCDEF");
      List<int> value = Hex.decodeWithNew("0xA1B2C3D4E5F6A7B8C9");
//      List<int> result = Hex.decodeWithNew();

      List<int> output = new List(value.length);
      List<int> state = new List(256);
      List<int> stateIJ = [0, 0];

      ARCFOUR.makeState(key, 0, key.length, state, 0);
      //print("####### ${Hex.encodeWithNew(state)}");
      ARCFOUR.operate(value, 0, value.length, state, 0, stateIJ, 0, output, 0);
      test.expect(Hex.encodeWithNew(output), "0x91b44728ff906c143d");
    });

    test.test("operateB", () {
      List<int> key = [0, 0];
      key.addAll(Hex.decodeWithNew("0xABCDEF"));
      List<int> value = [0, 0];
      value.addAll(Hex.decodeWithNew("0xA1B2C3D4E5F6A7B8C9"));

      List<int> output = new List(value.length);
      List<int> state = new List(256 + 2);
      List<int> stateIJ = [1, 1, 0, 0];

      ARCFOUR.makeState(key, 2, key.length - 2, state, 2);
      test.expect(Hex.encodeWithNew(state.sublist(2)), "0x41796a1452b58ea9590d2b1b5c252422ffcebc0b9f3d4250f69be50094a023556430d8e7b3dff4c6bbf91e1228935ec2e31fb885319ad27fa68a022ca2efd9ec8289c1cb9e4f532fbe5f7ae95d992eaa721a7c62cd7637210e1c77815718a384a707096febb05bf5f23b0cdaf11d88c929753c7036a4457463a82df3bdd58f34c5c883b4e1f8af6149c791cf6bab9dd656e613359639203ffe4c4e1943b7f7d73a9204e28b80ca47fb46b6deea58e42a87fcd0edb2db5473ad33cc010a7e05e0037db9c4400f7b386c678dd1c32610bf4d652790fd173e5ae844c0ddd41198f0a1ee0678516d866995486ea5ba689760fa164a32b108ac4b71668cae15dc9cd3");
      ARCFOUR.operate(value, 2, value.length - 2, state, 2, stateIJ, 2, output, 2);
      test.expect(Hex.encodeWithNew(output.sublist(2)), "0x91b44728ff906c143d");
    });

    test.test("operateC", () {
      List<int> key = Hex.decodeWithNew("0xA0A1A2A3A4A5A6A7A8A9B0B1B2B3B4B5B6B7B8B9C0C1C2C3C4C5C6C7C8C9D1D2");
      List<int> value = Hex.decodeWithNew("0xA0A1A2A3A4A5A6A7A8A9B0B1B2B3B4B5B6B7B8B9C0C1C2C3C4C5C6C7C8C9D1D2");
//      List<int> result = Hex.decodeWithNew();

      List<int> output = new List(value.length);
      List<int> state = new List(256);
      List<int> stateIJ = [0, 0];

      ARCFOUR.makeState(key, 0, key.length, state, 0);
      //print("####### ${Hex.encodeWithNew(state)}");
      ARCFOUR.operate(value, 0, value.length, state, 0, stateIJ, 0, output, 0);
      test.expect(Hex.encodeWithNew(output), "0x07df75ad3257de1b67f19348a8d562923a59d50d947a229272785185ba919788");
    });
  });
}
