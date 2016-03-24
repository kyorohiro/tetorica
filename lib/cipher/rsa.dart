library rsa;

//import 'bigint.dart';
import 'package:bignum/bignum.dart';
import 'dart:typed_data';
import 'hex.dart';

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
  static BigInteger compute(BigInteger m, BigInteger e, BigInteger n) {
    return m.modPow(e, n);
  }

  static List<int> decrypt(List<int> input, int len, BigInteger modulus, BigInteger exponent) {
    int modulusByteLength = modulus.bitLength() ~/ 8 + (modulus.bitLength() % 8 == 0 ? 0 : 1);
    List<int> paddedBlock = new Uint8List(modulusByteLength);
    List<int> output = [];

    if (len % modulusByteLength != 0) {
      throw {"message": " len % modulusByteLength != 0"};
    }
    for (int inputed = 0; inputed < len; inputed += modulusByteLength) {
      BigInteger cipherText = new BigInteger.fromBytes(1, input.sublist(inputed, inputed + modulusByteLength));
      BigInteger message = cipherText.modPow(exponent, modulus);
      var v = message.toByteArray();
      for (int i = v.length - 1, j = paddedBlock.length - 1; j >= 0; i--, j--) {
        paddedBlock[j] = (i >= 0 ? v[i] : 0);
      }
      if (paddedBlock[1] != 0x02) {
        throw {"message": " paddedBlock[1] != 0x02 "};
      }
//      print(">> ${paddedBlock[1]} : ${Hex.encodeWithNew(paddedBlock)}");
      //
      int actualDataStart = 2;
      for (; paddedBlock[actualDataStart] != 0; actualDataStart++) {}
      actualDataStart++;
//      print("${actualDataStart} ${paddedBlock[actualDataStart]}");

      //
//      print("# output: ${output}");
      output.addAll(paddedBlock.sublist(actualDataStart));
    }

    return output;
  }

  static List<int> encrypt(List<int> input, int len, BigInteger modulus, BigInteger exponent) {
    int modulusByteLength = modulus.bitLength() ~/ 8 + (modulus.bitLength() % 8 == 0 ? 0 : 1);

    int encryptedSize = 0;


    List<int> output = [];
    List<int> paddedBlock = new Uint8List(modulusByteLength);

    int blockSize = 0;
    for (int inputed = 0; inputed < len; inputed += blockSize, encryptedSize += blockSize) {
      print("${inputed}");
      //
      blockSize = ((len-inputed) < modulusByteLength - 11 ? (len-inputed): modulusByteLength - 11);
      int dummyDataLength = (modulusByteLength - blockSize - 1);
      int contentPoint = modulusByteLength - blockSize;

      // zero clear
      for (int j = 0; j < paddedBlock.length; j++) {
        paddedBlock[j] = 0;
      }

      // randomfilter
      for (int j = 0; j < dummyDataLength; j++) {
        paddedBlock[j] = j;
      }
      // random filter end sign
      paddedBlock[dummyDataLength] = 0;

      // block type
      paddedBlock[1] = 0x00;
      paddedBlock[1] = 0x02;

      // actual payload
      print(">>${contentPoint} ${blockSize} ${len} ${inputed}");
      for (int j = 0; j < blockSize; j++) {
        try {
        //  print(">>>>s [${j}] = ${input[j]}");
          paddedBlock[contentPoint + j] = input[j + inputed];
        } catch (e) {
          print("${paddedBlock.length} ${contentPoint} ${j} ${inputed} ${input.length}");
          throw e;
        }
      }

      BigInteger message = new BigInteger.fromBytes(1, paddedBlock);
      BigInteger c = message.modPow(exponent, modulus);
      //
      List<int> v = c.toByteArray();
      //print("output >> ${v.length} ${v[0]} ${v}");
      for (int j = 0, l=v.length-modulusByteLength; j < modulusByteLength; j++,l++) {
        output.add(v[l]);
      }
    }
    return output;
  }
}
/**
 ./a.out -e 0xbc
 --> 0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d
 ./a.out -d 0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d
--> bc
 */
