import 'package:test/test.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/turn.dart' as turn;
import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunAddressAttribute attrA = new turn.StunAddressAttribute(turn.StunMessageAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv4, 6881, "127.0.0.1");
    turn.StunAddressAttribute attrB = turn.StunAddressAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: mapped v6", () {
    turn.StunAddressAttribute attrA = new turn.StunAddressAttribute(turn.StunMessageAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv6, 6881, "2001:db8:0:0:0:0:0:9abc"); //"2001:db8::9abc");
    turn.StunAddressAttribute attrB = turn.StunAddressAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: change request true false", () {
    turn.StunChangeRequest attrA = new turn.StunChangeRequest(true, false);
    turn.StunChangeRequest attrB = turn.StunChangeRequest.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.changeIP, attrB.changeIP);
    unit.expect(attrA.changePort, attrB.changePort);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: change request false true", () {
    turn.StunChangeRequest attrA = new turn.StunChangeRequest(true, false);
    turn.StunChangeRequest attrB = turn.StunChangeRequest.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.changeIP, attrB.changeIP);
    unit.expect(attrA.changePort, attrB.changePort);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message userName", () {
    turn.StunBasicMessage attrA = new turn.StunBasicMessage(turn.StunMessageAttribute.userName, [1,2,3,4,5,6,7,8]);
    turn.StunBasicMessage attrB = turn.StunBasicMessage.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message password", () {
    turn.StunBasicMessage attrA = new turn.StunBasicMessage(turn.StunMessageAttribute.password, [1,2,3,4,5,6,7,8]);
    turn.StunBasicMessage attrB = turn.StunBasicMessage.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message integrity", () {
    turn.StunBasicMessage attrA = new turn.StunBasicMessage(
      turn.StunMessageAttribute.messageIntegrity, new List.filled(64, 2));
    turn.StunBasicMessage attrB = turn.StunBasicMessage.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: errorcode", () {
    turn.StunErrorCode attrA = new turn.StunErrorCode(400, "abcdefghijklmn");
    turn.StunErrorCode attrB = turn.StunErrorCode.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.code, attrB.code);
    unit.expect(attrA.pharse, attrB.pharse);
    unit.expect(attrA.encode().length, attrA.length+4);
  });
}
