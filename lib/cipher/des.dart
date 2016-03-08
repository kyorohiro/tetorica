library des_cipher;

//import 'dart:typed_data' as data;

//
// http://csrc.nist.gov/publications/fips/fips46-3/fips46-3.pdf
//

encrypt(List<int> key, List<int> iv, List<int> src) {
  bool isEncrypt = true;
  List<int> input = src;
  input = xorFun(input, iv, 8);
  //
  //
  List<int> ipBlock = permuteFunc(input, IP, 8);
  List<int> pc1key = permuteFunc(key, PC1, 7);

  for (int round = 0; round < 16; round++) {
    List<int> expansionBlock = permuteFunc(ipBlock.sublist(4), EX, 6);
    //
    if (isEncrypt) {
      rol(pc1key);
      if (!(round == 0 || round == 1 || round == 8 || round == 15)) {
        rol(pc1key);
      }
    }
    //
    List<int> subKey = permuteFunc(pc1key, PC2, 6);
    if (!isEncrypt) {
      ror(pc1key);
      if (!(round == 14 || round == 15 || round == 7 || round == 0)) {
        ror(pc1key);
      }
    }
    expansionBlock = xorFun(expansionBlock, subKey, 6);
    //
    //

    // Substitution; "copy" from updated expansion block to ciphertext block
    List<int> substitution_block = new List.filled(4, 0);
    substitution_block[0] = S1[(expansionBlock[0] & 0xFC) >> 2] << 4;
    substitution_block[0] |= S2[(expansionBlock[0] & 0x03) << 4 | (expansionBlock[1] & 0xF0) >> 4];
    substitution_block[1] = S3[(expansionBlock[1] & 0x0F) << 2 | (expansionBlock[2] & 0xC0) >> 6] << 4;
    substitution_block[1] |= S4[(expansionBlock[2] & 0x3F)];
    substitution_block[2] = S5[(expansionBlock[3] & 0xFC) >> 2] << 4;
    substitution_block[2] |= S6[(expansionBlock[3] & 0x03) << 4 | (expansionBlock[4] & 0xF0) >> 4];
    substitution_block[3] = S7[(expansionBlock[4] & 0x0F) << 2 | (expansionBlock[5] & 0xC0) >> 6] << 4;
    substitution_block[3] |= S8[(expansionBlock[5] & 0x3F)];
    //
    // Permutation
    List<int> pbox_target = permuteFunc(substitution_block, P, 4);

    // Recombination. XOR the pbox with left half and then switch sides.
    List<int> recomb_box = ipBlock.sublist(0, 4);
    ipBlock = ipBlock.sublist(4);

    xorFun(recomb_box, pbox_target, 4);
    ipBlock.addAll(recomb_box);
  }

  // Swap one last time
  List<int> recomb_box = ipBlock.sublist(0, 4);
  ipBlock = ipBlock.sublist(4);
  ipBlock.addAll(recomb_box);
  List<int> ciphertext = permuteFunc(ipBlock, IPm1, 8);
  return ciphertext;
}

void rol(List<int> target) {
  int carry_left, carry_right;
  carry_left = (target[0] & 0x80) >> 3;

  target[0] = (target[0] << 1) | ((target[1] & 0x80) >> 7);
  target[1] = (target[1] << 1) | ((target[2] & 0x80) >> 7);
  target[2] = (target[2] << 1) | ((target[3] & 0x80) >> 7);

  // special handling for byte 3
  carry_right = (target[3] & 0x08) >> 3;
  target[3] = (((target[3] << 1) | ((target[4] & 0x80) >> 7)) & ~0x10) | carry_left;

  target[4] = (target[4] << 1) | ((target[5] & 0x80) >> 7);
  target[5] = (target[5] << 1) | ((target[6] & 0x80) >> 7);
  target[6] = (target[6] << 1) | carry_right;
}

void ror(List<int> target) {
  int carry_left, carry_right;

  carry_right = (target[6] & 0x01) << 3;

  target[6] = (target[6] >> 1) | ((target[5] & 0x01) << 7);
  target[5] = (target[5] >> 1) | ((target[4] & 0x01) << 7);
  target[4] = (target[4] >> 1) | ((target[3] & 0x01) << 7);

  carry_left = (target[3] & 0x10) << 3;
  target[3] = (((target[3] >> 1) | ((target[2] & 0x01) << 7)) & ~0x08) | carry_right;

  target[2] = (target[2] >> 1) | ((target[1] & 0x01) << 7);
  target[1] = (target[1] >> 1) | ((target[0] & 0x01) << 7);
  target[0] = (target[0] >> 1) | carry_left;
}

encryptPer(List<int> src, int srcIndex, List<int> out, int outIndex) {
  ;
}

List<int> xorFun(List<int> v1, List<int> v2, int size) {
  List<int> ret = new List(v1.length);
  for (int i = 0, len = ret.length; i < len; i++) {
    if (i < size) {
      ret[i] = v1[i] ^ v2[i];
    } else {
      ret[i] = v1[i];
    }
  }
  return ret;
}

List<int> permuteFunc(List<int> v1, List<int> table, int byteSize) {
  List<int> ret = new List(byteSize);
  for (int i = 0, len = byteSize * 8; i < len; i++) {
    setBit(ret, i, getBit(v1, table[i] - 1));
  }
  return ret;
}

bool getBit(List<int> v1, int bit) {
  return (v1[bit ~/ 8] & (0x80 >> (bit % 8))) == 0 ? false : true;
}

void setBit(List<int> v1, int bit, bool v) {
  if (v) {
    v1[bit ~/ 8] |= (0x80 >> (bit % 8));
  } else {
    v1[bit ~/ 8] &= ~(0x80 >> (bit % 8));
  }
}

List<int> IP = [58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4, 62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8, 57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3, 61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7];
List<int> IPm1 = [40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31, 38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29, 36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27, 34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25];
List<int> PC1 = [57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26, 18, 10, 2, 59, 51, 43, 35, 27, 19, 11, 3, 60, 52, 44, 36, 63, 55, 47, 39, 31, 23, 15, 7, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45, 37, 29, 21, 13, 5, 28, 20, 12, 4];
List<int> PC2 = [14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4, 26, 8, 16, 7, 27, 20, 13, 2, 41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48, 44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32];
List<int> P = [16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25];
List<int> EX = [32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9, 8, 9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 17, 16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25, 24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32, 1];
List<int> S1 = [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7, 0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8, 4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0, 15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13];
List<int> S2 = [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10, 3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5, 0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15, 13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9];
List<int> S3 = [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8, 13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1, 13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7, 1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12];
List<int> S4 = [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15, 13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9, 10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4, 3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14];
List<int> S5 = [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9, 14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6, 4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14, 11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3];
List<int> S6 = [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11, 10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8, 9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6, 4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13];
List<int> S7 = [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1, 13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6, 1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2, 6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12];
List<int> S8 = [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7, 1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2, 7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8, 2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11];
