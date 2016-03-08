import 'package:test/test.dart' as unit;
import 'package:tetorica/net.dart';

void main() {
  unit.group("ipaddr", () {
    unit.test("localhost", () {
      IPAddr addrV4 = new IPAddr.fromString("127.0.0.1");
      IPAddr addrV4b = new IPAddr.fromString("127.255.255.255");
      IPAddr addrV6 = new IPAddr.fromString(":1");
      unit.expect(true, addrV4.isLocalHost());
      unit.expect(true, addrV4b.isLocalHost());
      unit.expect(true, addrV6.isLocalHost());
    });
    unit.test("localhost", () {
      IPAddr addrV4 = new IPAddr.fromString("255.255.255.255");
      IPAddr addrV6 = new IPAddr.fromString("ff02::1");
      unit.expect(true, addrV4.isBroadcast());
      unit.expect(true, addrV6.isBroadcast());
    });
  });

  unit.group("ipconv v4", () {
    unit.test("127.0.255.1", () {
      unit.expect(IPConv.toIPString([127, 0, 255, 1]), "127.0.255.1");
    });
    unit.test("127.0.255.1", () {
      unit.expect(IPConv.toRawIP("127.0.255.1"), [127, 0, 255, 1]);
    });
    unit.test("0.0.255.1", () {
      unit.expect(IPConv.toRawIP("0.0.255.1"), [0, 0, 255, 1]);
    });
    unit.test("www.a.exsample.com", () async {
      try {
        unit.expect(IPConv.toRawIP("www.a.exsample.com"), [0, 0, 255, 1]);
        unit.expect(true, false);
      } catch(e) {

      }
    });
  });

  unit.group("ipconv v6", () {
    unit.test("2001:db8:20:3:1000:100:20:3", () {
      unit.expect(IPConv.toIPString([0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]), "2001:db8:20:3:1000:100:20:3");
    });

    unit.test("2001:db8:20:3:1000:100:20:3", () {
      unit.expect(IPConv.toRawIP("2001:db8:20:3:1000:100:20:3"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]);
    });

    unit.test("2001:0db8:0020:0003:1000:0100:0020:0003", () {
      unit.expect(IPConv.toRawIP("2001:0db8:0020:0003:1000:0100:0020:0003"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]);
    });
    unit.test("2001:0db8:0000:0000:0000:0000:0000:9abc", () {
      unit.expect(IPConv.toRawIP("2001:0db8:0000:0000:0000:0000:0000:9abc"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0xbc]);
    });
    unit.test("2001:db8::9abc", () {
      unit.expect(IPConv.toRawIP("2001:db8::9abc"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0xbc]);
    });
  });
}
