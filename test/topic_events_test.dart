import 'package:test/test.dart';
import 'package:topic_events/topic_events.dart';

void main() {
  test('works', () {
    const discA = 'A';
    const discB = 'B';
    const discX = 'X';

    final inA = TopicEvent(discA, 'abc', 'def');
    final inB = TopicEvent(discB, 'ghi', 'jkl');
    final inX = TopicEvent(discX, 'mno', 'pqr');

    final outA = TopicEvent(inA.topic, inA.cmd + discA, inA.payload + discA);
    final outB = TopicEvent(inB.topic, inB.cmd + discB, inB.payload + discB);

    final List<TopicEvent> incomingTestEvents = [inA, inX, inB];
    final List<TopicEvent> expectedReplyEvents = [outA, outB];

    final transport = SyncTestTopicEventTransport(incomingTestEvents);
    final managerA = TestManager(discA);
    final managerB = TestManager(discB);
    final broker = TopicEventBroker(transport)
      ..addManager(managerA)
      ..addManager(managerB);

    expect(transport.outgoing, isEmpty);
    expect(managerA.incoming, isEmpty);
    expect(managerB.incoming, isEmpty);

    broker.listen();

    expect(transport.outgoing, expectedReplyEvents);
    expect(managerA.incoming, [inA]);
    expect(managerB.incoming, [inB]);
  });
}

class SyncTestTopicEventTransport extends TopicEventTransport {
  final List<TopicEvent> incoming;
  final List<TopicEvent> outgoing = [];

  SyncTestTopicEventTransport(this.incoming);

  void receive(TopicEvent event) => onIncoming(event);

  @override
  void onOutgoing(TopicEvent event) => outgoing.add(event);

  @override
  void onListen() => incoming.forEach(onIncoming);
}

class TestManager extends TopicManager {
  final Topic discriminator;
  final List<TopicEvent> incoming = [];

  TestManager(this.discriminator);

  @override
  void handleEvent(TopicEvent event) {
    incoming.add(event);
    writeEvent(event.cmd + discriminator, event.payload + discriminator);
  }

  @override
  Topic get topic => discriminator;
}
