import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart';
import 'dart:async';

void main() {
  unit.group("rba", (){

    unit.test("hetimadata_cache 1: init", () async{
      HetimaDataMemory dummy = new HetimaDataMemory();
      HetimaDataSerialize cache = new HetimaDataSerialize(dummy);
      List<Future> f = [];
      f.add(cache.write([1,2,3], 0));
      f.add(cache.write([4,5,6], 3));

      await Future.wait(f);
      cache.getLength();
      unit.expect(await cache.getLength(), 6);
      unit.expect((await cache.read(0, 1)).buffer,[1]);
      unit.expect((await cache.read(1, 2)).buffer,[2,3]);
      unit.expect((await cache.read(0, 6)).buffer,[1,2,3,4,5,6]);
    });
  });
}
