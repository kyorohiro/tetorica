import 'package:test/test.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/turn.dart' as turn;
import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunMessageHeader headerA = new turn.StunMessageHeader(turn.StunMessageHeader.bindingResponse);
    headerA.attributes.add(
      new turn.StunAddressAttribute(
        turn.StunMessageAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv4, 6881, "127.0.0.1"));
    headerA.attributes.add(
      new turn.StunChangeRequest(true, false));
    headerA.attributes.add(
      new turn.StunBasicMessage(turn.StunMessageAttribute.userName, [1,2,3,4,5,6,7,8]));
    headerA.attributes.add(
      new turn.StunErrorCode(400, "abcdefghijklmn"));

    turn.StunMessageHeader headerB = turn.StunMessageHeader.decode(headerA.encode(), 0);
    unit.expect(headerA.type, headerB.type);
    unit.expect(headerA.attributes.length, headerB.attributes.length);
    /*
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
    unit.expect(attrA.encode().length, attrA.length+4);
    */
  });
}
