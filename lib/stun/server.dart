part of hetimanet_stun;

class StunServer {
  net.TetSocketBuilder builder;
  String primaryIP;
  int primaryPort;

  String secondaryIP;
  int secondaryPort;

  net.TetUdpSocket primaryUdp;
  net.TetUdpSocket secondaryUdp;
  StunServer(this.builder, this.primaryIP, this.primaryPort, this.secondaryIP, this.secondaryPort) {}

  Future prepare() async {
    primaryUdp = builder.createUdpClient();
    secondaryUdp = builder.createUdpClient();
    await primaryUdp.bind(primaryIP, primaryPort);
    await secondaryUdp.bind(secondaryIP, secondaryPort);
  }

  
}
