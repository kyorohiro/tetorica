import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart';
import 'package:tetorica/core_html5.dart';

void main() {
  unit.group("rba", (){

    //
    unit.test("add 0", () {
      HetimaDataFS dataFs = new HetimaDataFS("test",erace:true);
      return dataFs.write([1,2,3], 0).then((WriteResult r) {
        return dataFs.read(0, 3);
      }).then((ReadResult r) {
        unit.expect(r.buffer,[1,2,3]);
      });
    });

    //
    unit.test("add 1", () {
      HetimaDataFS dataFs = new HetimaDataFS("test",erace:true);
      return dataFs.write([1,2,3], 1).then((WriteResult r) {
        return dataFs.read(0, 4);
      }).then((ReadResult r) {
        unit.expect(r.buffer,[0,1,2,3]);
      });
    });
  });
}
