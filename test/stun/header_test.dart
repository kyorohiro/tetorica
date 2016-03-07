import 'package:test/test.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/stun.dart' as turn;
import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunMessageHeader headerA = new turn.StunMessageHeader(turn.StunMessageHeader.bindingResponse);
    headerA.attributes.add(
      new turn.StunAddressAttribute(
        turn.StunAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv4, 6881, "127.0.0.1"));
    headerA.attributes.add(
      new turn.StunChangeRequest(true, false));
    headerA.attributes.add(
      new turn.StunBasicMessage(turn.StunAttribute.userName, [1,2,3,4,5,6,7,8]));
    headerA.attributes.add(
      new turn.StunErrorCode(400, "abcdefghijklmn"));

    turn.StunMessageHeader headerB = turn.StunMessageHeader.decode(headerA.encode(), 0);
    unit.expect(headerA.type, headerB.type);
    unit.expect(headerA.attributes.length, headerB.attributes.length);
    unit.expect(headerA.attributes[0], headerB.attributes[0]);
    unit.expect(headerA.attributes[1], headerB.attributes[1]);
  });
}
