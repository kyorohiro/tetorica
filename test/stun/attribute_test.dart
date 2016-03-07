import 'package:test/test.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/turn.dart' as turn;
import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunAddressAttribute attrA = new turn.StunAddressAttribute(
      turn.StunMessageAttribute.mappedAddress,
      turn.StunAddressAttribute.familyIPv4,
      6881,
      "127.0.0.1");
    turn.StunAddressAttribute attrB = turn.StunAddressAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
  });
}
