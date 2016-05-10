import 'dart:typed_data' show Uint8List;
import 'package:tetorica/cipher/sha1.dart';
import 'package:crypto/crypto.dart' as cry;
import 'dart:math' as math;

void main() {
  int size = 10000;
  List<int> data = new Uint8List(size);

  math.Random r = new math.Random();
  for(int i=0;i<size;i++) {
    data[i] = r.nextInt(0xff) & 0xff;
  }

  cry.SHA1 sha1 = new cry.SHA1();
  SHA1 sha = new SHA1();

  sha1.add(data);
  {
    var v = sha1.close();
    print(" ${v} ${v.length}");
  }
  {
    print(sha.calcSha1(new Uint8List.fromList(data)));
  }
}
