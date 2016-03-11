part of hetimanet_stun;

class StunServer {
  net.TetSocketBuilder builder;
  String primaryIP;
  int primaryPort;

  String secondaryIP;
  int secondaryPort;

  net.TetUdpSocket primaryUdp;
  net.TetUdpSocket primaryUdpWithDiffPort;
  net.TetUdpSocket secondaryUdp;
  net.TetUdpSocket secondaryUdpWithDiffPort;

  StunServer(this.builder, this.primaryIP, this.primaryPort, this.secondaryIP, this.secondaryPort) {}

  Future go() async {
    primaryUdp = builder.createUdpClient();
    primaryUdpWithDiffPort = builder.createUdpClient();
    secondaryUdp = builder.createUdpClient();
    secondaryUdpWithDiffPort = builder.createUdpClient();

    await primaryUdp.bind(primaryIP, primaryPort);
    await primaryUdpWithDiffPort.bind(primaryIP, secondaryPort);
    await secondaryUdp.bind(secondaryIP, primaryPort);
    await secondaryUdpWithDiffPort.bind(secondaryIP, secondaryPort);
  }

  Future primaryAct() async {
    await for(net.TetReceiveUdpInfo info in primaryUdp.onReceive) {
      try {
        StunHeader header = await StunHeader.decode(info.data, 0);
        bool changeIP = false;
        bool changePort = false;
        bool ref3489 = (header.rfcVersion() == StunRfcVersion.ref3489);

        if(header.haveChangeRequest()) {
          StunChangeRequestAttribute attr = header.changeReuest();
          changeIP = attr.changeIP;
          changePort = attr.changePort;
        }

        net.TetUdpSocket udpSock = null;
        if(changeIP == false && changePort == false) {
          udpSock = primaryUdp;
        } else if(changeIP == true && changePort == true) {
          udpSock = secondaryUdpWithDiffPort;
        } else if(changeIP == true && changePort == false) {
          udpSock = primaryUdpWithDiffPort;
        } else if(changeIP == false && changePort == true) {
          udpSock = secondaryUdp;
        }
//        udpSock.send(, address, port)
        //
      } catch(e,t) {
        ;
      }
    }
  }

}
