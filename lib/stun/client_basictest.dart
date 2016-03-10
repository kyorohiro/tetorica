part of hetimanet_stun;

class StunClientBasicTest {
  StunClient client;
  StunClientBasicTest(client) {
    ;
  }

  Future prepare() async {
    return await client.prepare();
  }

  Future<List<StunNatType>> testBasic(List<net.IPAddr> ipList) async {
    StunClientSendHeaderResult test1Result = null;
    StunClientSendHeaderResult test2Result = null;
    StunClientSendHeaderResult test3Result = null;
    try {
      test1Result = await test001();
      if (false == test1Result.passed()) {
        return [StunNatType.stunServerThrowError];
      }
    } catch (e) {
      return [StunNatType.blockUdp];
    }

    try {
      test2Result = await test002();
      if (test2Result.passed()) {
        if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return [StunNatType.openInternet];
        } else {
          return [StunNatType.fullConeNat];
        }
      }
    } catch (e) {}

// todo
// retest1
    try {
      test3Result = await test003();
      if (test3Result.passed()) {
        if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return [StunNatType.restricted];
        } else {
          return [StunNatType.portRestricted];
        }
      }
    } catch (e) {}

    return [StunNatType.symmetricNat];
  }


  //
  //  In test I, the client sends a
  //  STUN Binding Request to a server, without any flags set in the
  //  CHANGE-REQUEST attribute, and without the RESPONSE-ADDRESS attribute.
  //  This causes the server to send the response back to the address and
  //  port that the request came from.
  Future<StunClientSendHeaderResult> test001({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    if (version == StunRfcVersion.ref3489) {
      header.attributes.add(new StunChangeRequestAttribute(false, false));
    }
    return await client.sendHeader(header);
  }

  //
  // In test II, the client sends a
  // Binding Request with both the "change IP" and "change port" flags
  // from the CHANGE-REQUEST attribute set.
  Future<StunClientSendHeaderResult> test002({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(true, true));
    return await client.sendHeader(header);
  }

  //
  // In test III, the client sends
  // a Binding Request with only the "change port" flag set.
  Future test003({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(false, true));
    return await client.sendHeader(header);
  }
}
