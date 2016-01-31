// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dart_hetimanet.test;
import './hetihttpresponse_test_b.dart' as httpresponse_b;
import './hetihttpresponse_test_c.dart' as httpresponse_c;
import './hetihttpresponse_test_d.dart' as httpresponse_d;
import './hetiudpsocketsimu_test.dart' as hetiudpsocketsimu_test;
import './httpurldecoder_test.dart' as httpurldecoder_test;
main() {
  httpresponse_b.main();
  httpresponse_c.main();
  httpresponse_d.main();
  hetiudpsocketsimu_test.main();
  httpurldecoder_test.main();
}
