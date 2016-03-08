//import 'package:tetorica/cipher/des.dart';

main() {
  for(int i=0;i<100;i++) {
    print("##[${i}] [[${i % 2}]]# ${(i - 1) >> 1} , ${4 + (i >> 1)}");
  }
}
