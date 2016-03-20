// http://csrc.nist.gov/publications/fips/fips197/fips-197.pdf
// http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf
library aes;

import 'dart:typed_data';

class AES {
  static void xor(List<int> target, int targetIndex, List<int> src, int srcIndex, int length) {
    for (int i = 0; i < length; i++) {
      target[targetIndex++] ^= src[srcIndex++];
    }
  }

  static void rotExKeyItem(List<int> word, int index) {
    int tmp;
    tmp = word[index + 0];
    word[index + 0] = word[index + 1];
    word[index + 1] = word[index + 2];
    word[index + 2] = word[index + 3];
    word[index + 3] = tmp;
  }

  static void subExKeyItem(List<int> word, int index) {
    for (int i = 0; i < 4; i++, index++) {
      word[index] = sbox[(word[index] & 0xF0) >> 4][word[index] & 0x0F];
    }
  }

  //
  // 0 4 8 c
  // 1 5 9 d
  // 2 6 a e
  // 3 7 b f
  static void addRoundKey(List<int> state, int stateIndex, List<int> word, int wordIndex) {
    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 4; r++) {
        state[r + 4 * c + stateIndex] = state[r + 4 * c + stateIndex] ^ word[4 * c + r + wordIndex];
      }
    }
  }

  static void subBytes(List<int> state, int stateIndex) {
    for (int i = stateIndex, end = stateIndex + 16; i < end; i++) {
      state[i] = sbox[(state[i] & 0xF0) >> 4][state[i] & 0x0F];
    }
  }

  // 5.1.2
  //        r
  //  0 4 8 c
  //  1 5 9 d
  //  2 6 a e
  //c 3 7 b f
  static void shiftRows(List<int> state, int stateIndex) {
    int tmp;
    tmp = state[1 + 4 * 0 + stateIndex];
    state[1 + 4 * 0 + stateIndex] = state[1 + 4 * 1 + stateIndex];
    state[1 + 4 * 1 + stateIndex] = state[1 + 4 * 2 + stateIndex];
    state[1 + 4 * 2 + stateIndex] = state[1 + 4 * 3 + stateIndex];
    state[1 + 4 * 3 + stateIndex] = tmp;

    tmp = state[2 + 4 * 0 + stateIndex];
    state[2 + 4 * 0 + stateIndex] = state[2 + 4 * 2 + stateIndex];
    state[2 + 4 * 2 + stateIndex] = tmp;
    tmp = state[2 + 4 * 1 + stateIndex];
    state[2 + 4 * 1 + stateIndex] = state[2 + 4 * 3 + stateIndex];
    state[2 + 4 * 3 + stateIndex] = tmp;

    tmp = state[3 + 4 * 3 + stateIndex];
    state[3 + 4 * 3 + stateIndex] = state[3 + 4 * 2 + stateIndex];
    state[3 + 4 * 2 + stateIndex] = state[3 + 4 * 1 + stateIndex];
    state[3 + 4 * 1 + stateIndex] = state[3 + 4 * 0 + stateIndex];
    state[3 + 4 * 0 + stateIndex] = tmp;
  }

  static int xtime(int x) {
    return (x << 1) ^ (((x & 0x80) != 0) ? 0x1b : 0x00);
  }

  static int dot(int x, int y) {
    int product = 0;
    for (int mask = 0x01; mask != 0; mask = (mask << 1) & 0xFF) {
      if (y & mask != 0) {
        product ^= x;
      }
      x = xtime(x);
    }
    return product;
  }

  // 5.1.3
  static void mixColumns(List<int> state, int stateIndex) {
    int t1;
    int t2;
    int t3;
    int t4;
    for (int c = 0; c < 4; c++) {
      t1 = dot(2, state[0 + 4 * c + stateIndex]) ^ dot(3, state[1 + 4 * c + stateIndex]) ^ state[2 + 4 * c + stateIndex] ^ state[3 + 4 * c + stateIndex];
      t2 = state[0 + 4 * c + stateIndex] ^ dot(2, state[1 + 4 * c + stateIndex]) ^ dot(3, state[2 + 4 * c + stateIndex]) ^ state[3 + 4 * c + stateIndex];
      t3 = state[0 + 4 * c + stateIndex] ^ state[1 + 4 * c + stateIndex] ^ dot(2, state[2 + 4 * c + stateIndex]) ^ dot(3, state[3 + 4 * c + stateIndex]);
      t4 = dot(3, state[0 + 4 * c + stateIndex]) ^ state[1 + 4 * c + stateIndex] ^ state[2 + 4 * c + stateIndex] ^ dot(2, state[3 + 4 * c + stateIndex]);

      state[0 + 4 * c + stateIndex] = t1;
      state[1 + 4 * c + stateIndex] = t2;
      state[2 + 4 * c + stateIndex] = t3;
      state[3 + 4 * c + stateIndex] = t4;
    }
  }

  // 5.3.1
  //
  //        r
  //  0 4 8 c
  //  1 5 9 d
  //  2 6 a e
  //c 3 7 b f
  static void invShiftRows(List<int> state, int stateIndex) {
    int tmp;
    tmp = state[1 + 4 * 2 + stateIndex];
    state[1 + 4 * 2 + stateIndex] = state[1 + 4 * 1 + stateIndex];
    state[1 + 4 * 1 + stateIndex] = state[1 + 4 * 0 + stateIndex];
    state[1 + 4 * 0 + stateIndex] = state[1 + 4 * 3 + stateIndex];
    state[1 + 4 * 3 + stateIndex] = tmp;

    tmp = state[2 + 4 * 0 + stateIndex];
    state[2 + 4 * 0 + stateIndex] = state[2 + 4 * 2 + stateIndex];
    state[2 + 4 * 2 + stateIndex] = tmp;
    tmp = state[2 + 4 * 1 + stateIndex];
    state[2 + 4 * 1 + stateIndex] = state[2 + 4 * 3 + stateIndex];
    state[2 + 4 * 3 + stateIndex] = tmp;

    tmp = state[3 + 4 * 0 + stateIndex];
    state[3 + 4 * 0 + stateIndex] = state[3 + 4 * 1 + stateIndex];
    state[3 + 4 * 1 + stateIndex] = state[3 + 4 * 2 + stateIndex];
    state[3 + 4 * 2 + stateIndex] = state[3 + 4 * 3 + stateIndex];
    state[3 + 4 * 3 + stateIndex] = tmp;
  }

  static void invSubBytes(List<int> state, int stateIndex) {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        state[r + 4 * c + stateIndex] = invSbox[(state[r + 4 * c + stateIndex] & 0xF0) >> 4][state[r + 4 * c + stateIndex] & 0x0F];
      }
    }
  }

  static void invMixColumns(List<int> state, int stateIndex) {
    int t1;
    int t2;
    int t3;
    int t4;
    for (int c = 0; c < 4; c++) {
      t1 = dot(0x0e, state[0 + 4 * c + stateIndex]) ^ dot(0x0b, state[1 + 4 * c + stateIndex]) ^ dot(0x0d, state[2 + 4 * c + stateIndex]) ^ dot(0x09, state[3 + 4 * c + stateIndex]);
      t2 = dot(0x09, state[0 + 4 * c + stateIndex]) ^ dot(0x0e, state[1 + 4 * c + stateIndex]) ^ dot(0x0b, state[2 + 4 * c + stateIndex]) ^ dot(0x0d, state[3 + 4 * c + stateIndex]);
      t3 = dot(0x0d, state[0 + 4 * c + stateIndex]) ^ dot(0x09, state[1 + 4 * c + stateIndex]) ^ dot(0x0e, state[2 + 4 * c + stateIndex]) ^ dot(0x0b, state[3 + 4 * c + stateIndex]);
      t4 = dot(0x0b, state[0 + 4 * c + stateIndex]) ^ dot(0x0d, state[1 + 4 * c + stateIndex]) ^ dot(0x09, state[2 + 4 * c + stateIndex]) ^ dot(0x0e, state[3 + 4 * c + stateIndex]);

      state[0 + 4 * c + stateIndex] = t1;
      state[1 + 4 * c + stateIndex] = t2;
      state[2 + 4 * c + stateIndex] = t3;
      state[3 + 4 * c + stateIndex] = t4;
    }
  }

  static int calcNb(int keyLength) => 4;
  static int calcNk(int keyLength) => keyLength ~/ 4;
  static int calcNr(int keyLength) => (keyLength >> 2) + 6;
  static int calcExKeyItemLength(int keyLength) => calcNb(keyLength) * (calcNr(keyLength) + 1);
  static int calcExKeyLength(int keyLength) => calcExKeyItemLength(keyLength)*4;

  static createExKeyFromKey(List<int> key, int keyBytesLength, List<int> outputExKey) {
    int nb = calcNb(keyBytesLength);
    int nk = calcNk(keyBytesLength);
    int exKeyItemLength = calcExKeyItemLength(keyBytesLength);

    for (int i = 0, len = nk * nb; i < len; i++) {
      outputExKey[i] = key[i];
    }

    //
    int rcon = 0x01;
    for (int i = nk; i < exKeyItemLength; i++) {
      outputExKey[4 * i + 0] = outputExKey[4 * (i - 1) + 0];
      outputExKey[4 * i + 1] = outputExKey[4 * (i - 1) + 1];
      outputExKey[4 * i + 2] = outputExKey[4 * (i - 1) + 2];
      outputExKey[4 * i + 3] = outputExKey[4 * (i - 1) + 3];
      if (i % nk == 0) {
        rotExKeyItem(outputExKey, 4 * i);
        subExKeyItem(outputExKey, 4 * i);
        if (i % 36 == 0) {
          rcon = 0x1b;
        }
        outputExKey[4 * i + 0] ^= rcon;
        rcon = (rcon << 1) & 0xff;
      } else if (nk > 6 && (i % nk) == 4) {
        subExKeyItem(outputExKey, 4 * i);
      }
      outputExKey[4 * i + 0] ^= outputExKey[4 * (i - nk) + 0];
      outputExKey[4 * i + 1] ^= outputExKey[4 * (i - nk) + 1];
      outputExKey[4 * i + 2] ^= outputExKey[4 * (i - nk) + 2];
      outputExKey[4 * i + 3] ^= outputExKey[4 * (i - nk) + 3];
    }
  }

  static encryptWithCBC(List<int> input, List<int> iv, List<int> key, List<int> output) {
    //
    int exKeyLength = 4 * AES.calcExKeyItemLength(key.length);
    List<int> exKeyBase = new Uint8List(exKeyLength);
    List<int> exKey = new Uint8List.fromList(exKeyBase);
    createExKeyFromKey(key, key.length, exKeyBase);

    for (int inputed = 0, outputed = 0, len = input.length; inputed < len; inputed += 16, outputed += 16) {
      //
      // CBC
      if (inputed == 0) {
        xor(input, 0, iv, 0, iv.length);
      } else {
        xor(input, inputed, output, outputed - 16, 16);
      }

      //
      // AES
      for (int i = 0; i < exKeyLength; i++) {
        exKey[i] = exKeyBase[i];
      }
      AES.encrypt(input, inputed, key.length, exKey, output, outputed);
    }
  }

  static decryptWithCBC(List<int> input, List<int> iv, List<int> key, List<int> output) {
    //
    int exKeyLength = AES.calcExKeyLength(key.length);
    List<int> exKeyBase = new Uint8List(exKeyLength);
    List<int> exKey = new Uint8List.fromList(exKeyBase);
    createExKeyFromKey(key, key.length, exKeyBase);

    //
    for (int len = input.length, inputed = len - 16, outputed = len - 16; inputed >= 0; inputed -= 16, outputed -= 16) {
      //
      // AES
      for (int i = 0; i < exKeyLength; i++) {
        exKey[i] = exKeyBase[i];
      }
      AES.decrypt(input, inputed, key.length, exKey, output, outputed);

      //
      // CBC
      if (inputed == 0) {
        xor(output, 0, iv, 0, iv.length);
      } else {
        xor(output, inputed, input, inputed - 16, 16);
      }
    }
  }

  static decrypt(List<int> input, int inputIndex, int keyLength, List<int> exKey, List<int> output, int outputIndex) {
    int Nr = calcNr(keyLength);
    List<int> state = input; //new Uint8List.fromList(input.sublist(inputIndex, inputIndex+16));
    addRoundKey(state, inputIndex, exKey, Nr * 4 * 4);

    for (int round = Nr; round > 0; round--) {
      invShiftRows(state, inputIndex);
      invSubBytes(state, inputIndex);
      addRoundKey(state, inputIndex, exKey, (round - 1) * 4 * 4);
      if (round > 1) {
        invMixColumns(state, inputIndex);
      }
    }
    for (int i = 0; i < 16; i++) {
      output[i + outputIndex] = state[i + inputIndex];
    }
  }

  static encrypt(List<int> input, int inputIndex, int keyLength, List<int> exKey, List<int> output, int outputIndex) {
    int Nr = calcNr(keyLength);
    List<int> state = input; //new Uint8List.fromList(input.sublist(inputIndex, inputIndex+16));

    // 5.1
    // cipher
    addRoundKey(state, inputIndex, exKey, 0);
    for (int round = 0; round < Nr; round++) {
      subBytes(state, inputIndex);
      shiftRows(state, inputIndex);
      if (round < (Nr - 1)) {
        mixColumns(state, inputIndex);
      }
      addRoundKey(state, inputIndex, exKey, (round + 1) * 4 * 4);
    }
    for (int i = 0; i < 16; i++) {
      output[i + outputIndex] = state[i + inputIndex];
    }
  }

  static List<List<int>> sbox = [
    [0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76],
    [0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0],
    [0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15],
    [0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75],
    [0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84],
    [0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf],
    [0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8],
    [0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2],
    [0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73],
    [0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb],
    [0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79],
    [0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08],
    [0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a],
    [0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e],
    [0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf],
    [0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16]
  ];

  static List<List<int>> invSbox = [
    [0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb],
    [0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb],
    [0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e],
    [0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25],
    [0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92],
    [0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84],
    [0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06],
    [0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b],
    [0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73],
    [0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e],
    [0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b],
    [0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4],
    [0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f],
    [0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef],
    [0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61],
    [0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d],
  ];
}
