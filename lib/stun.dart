library hetimanet_stun;

import 'dart:async';
import 'dart:convert' as conv;
import 'dart:math' as math;
import 'dart:typed_data';

import 'core.dart' as core;
import 'net.dart' as net;

part 'stun/attribute.dart';
part 'stun/attribute_address.dart';
part 'stun/attribute_basic.dart';
part 'stun/attribute_changerequest.dart';
part 'stun/attribute_errorcode.dart';
part 'stun/header.dart';
part 'stun/header_transactionid.dart';

class TurnClient {}

// stun.l.google.com:19302
// https://tools.ietf.org/html/rfc5389
// https://tools.ietf.org/html/rfc3489
// 3478
// 5349
//stun   3478/tcp   Session Traversal Utilities for NAT (STUN) port
//  stun   3478/udp   Session Traversal Utilities for NAT (STUN

//Full Cone
//Restricted Cone
//Port Restricted Cone
//Symmetric

class StunClientSendHeaderResult {
  String remoteAddress;
  int remotePort;
  StunHeader header;
  StunClientSendHeaderResult(this.remoteAddress, this.remotePort, this.header) {}

  bool passed() {
    return (false == header.haveError() && null != header.getAttribute([StunAttribute.mappedAddress]));
  }
}

enum StunNatType { openInternet, blockUdp, symmetricUdp, fullConeNat, symmetricNat, restricted, portRestricted, stunServerThrowError }

// https://tools.ietf.org/html/rfc3489
// 9 Client Behavior
class StunClient {
  net.TetSocketBuilder builder;
  String address;
  int port;
  String stunServer;
  int stunServerPort;
  Duration _defaultTimeout = new Duration(seconds: 2);

  Map<StunTransactionID, Completer<StunClientSendHeaderResult>> cash = {};
  net.TetUdpSocket _udp = null;

  StunClient(this.builder, this.stunServer, this.stunServerPort, {this.address: "0.0.0.0", this.port: 0}) {
    ;
  }

  Future prepare() async {
    if (_udp != null) {
      return;
    }

    net.TetUdpSocket u = builder.createUdpClient();
    await u.bind(address, port);
    _udp = u;
    _udp.onReceive.listen((net.TetReceiveUdpInfo info) {
      print("## --------- receive packet ##");
      print("## ${info.data}");
      print("## ${info.remoteAddress}");
      print("## ${info.remotePort}");
      print("## --------- ##");
      StunHeader header = StunHeader.decode(info.data, 0);
      print("${header.toString()}");
      print("## --------- ##");
      if (cash.containsKey(header.transactionID)) {
        cash.remove(header.transactionID).complete(new StunClientSendHeaderResult(info.remoteAddress, info.remotePort, header));
      }
    });
  }

  Future close() async {
    if (_udp != null) {
      _udp.close();
      _udp = null;
    }
  }

  Future<StunNatType> testBasic(List<net.IPAddr> ipList) async {
    StunClientSendHeaderResult test1Result = null;
    StunClientSendHeaderResult test2Result = null;
    StunClientSendHeaderResult test3Result = null;
    try {
      test1Result = await test001();
      if (false == test1Result.passed()) {
        return StunNatType.stunServerThrowError;
      }
    } catch (e) {
      return StunNatType.blockUdp;
    }

    try {
      test2Result = await test002();
      if (test2Result.passed()) {
        if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return StunNatType.openInternet;
        } else {
          return StunNatType.fullConeNat;
        }
      }
    } catch (e) {}


// todo
// retest1
    try {
      test3Result = await test003();
      if (test3Result.passed()) {
        if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return StunNatType.restricted;
        } else {
          return StunNatType.portRestricted;
        }
      }
    } catch (e) {}

    return StunNatType.symmetricNat;
  }

  Future<StunClientSendHeaderResult> sendHeader(StunHeader header, {Duration timeout}) async {
    if (timeout == null) {
      timeout = _defaultTimeout;
    }
    if (cash.containsKey(header.transactionID)) {
      header.transactionID = new StunTransactionID.random();
    }
    cash[header.transactionID] = new Completer();
    _udp.send(header.encode(), stunServer, stunServerPort);
    cash[header.transactionID].future.timeout(timeout, onTimeout: () {
      cash.remove(header.transactionID).completeError({"mes": "timeout"});
    });
    return cash[header.transactionID].future;
  }

  //
  //  In test I, the client sends a
  //  STUN Binding Request to a server, without any flags set in the
  //  CHANGE-REQUEST attribute, and without the RESPONSE-ADDRESS attribute.
  //  This causes the server to send the response back to the address and
  //  port that the request came from.
  Future<StunClientSendHeaderResult> test001() async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest);
    header.attributes.add(new StunChangeRequestAttribute(false, false));
    return await sendHeader(header);
  }

  //
  // In test II, the client sends a
  // Binding Request with both the "change IP" and "change port" flags
  // from the CHANGE-REQUEST attribute set.
  Future<StunClientSendHeaderResult> test002() async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest);
    header.attributes.add(new StunChangeRequestAttribute(true, true));
    return await sendHeader(header);
  }

  //
  // In test III, the client sends
  // a Binding Request with only the "change port" flag set.
  Future test003() async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest);
    header.attributes.add(new StunChangeRequestAttribute(false, true));
    return await sendHeader(header);
  }
}
