import 'package:test/test.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/turn.dart' as turn;
import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: ", () {
    hetima.TetBufferPlus buffer = new hetima.TetBufferPlus(3);
    unit.expect(3, buffer.length);

    buffer[0] = 1;
    buffer[1] = 2;
    buffer[2] = 3;
    try {
      buffer[3] = 4;
      unit.expect(true, false);
    } catch (e) {
      unit.expect(true, true);
    }
    buffer.expandBuffer(5);
    buffer[3] = 4;
    buffer[4] = 5;
    unit.expect(2, buffer[1]);
    unit.expect(5, buffer[4]);
    unit.expect(5, buffer.length);
  });
}
