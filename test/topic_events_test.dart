import 'package:test/test.dart';
import 'package:topic_events/topic_events.dart';

void main() {
  test('works', () {
    const topA = 'A';
    const topB = 'B';
    const topX = 'X';

    final reqA = TopicEvent(topA, 'abc', 'def');
    final reqB = TopicEvent(topB, 'ghi', 'jkl');
    final reqX = TopicEvent(topX, 'mno', 'pqr');

    final repA = TopicEvent(reqA.topic, reqA.cmd + topA, reqA.payload + topA);
    final repB = TopicEvent(reqB.topic, reqB.cmd + topB, reqB.payload + topB);

    final transport = SyncTestTopicEventTransport();
    final managerA = TestManager(topA);
    final managerB = TestManager(topB);

    TopicEventBroker()
      ..addManager(managerA)..addManager(managerB)
      ..setTransport(transport);

    expect(transport.replies, isEmpty);
    expect(managerA.requests, isEmpty);
    expect(managerB.requests, isEmpty);

    transport.publishTestEvent(reqA);

    expect(transport.replies, [repA]);
    expect(managerA.requests, [reqA]);
    expect(managerB.requests, isEmpty);

    transport.publishTestEvent(reqX);

    expect(transport.replies, [repA]);
    expect(managerA.requests, [reqA]);
    expect(managerB.requests, isEmpty);

    transport.publishTestEvent(reqB);

    expect(transport.replies, [repA, repB]);
    expect(managerA.requests, [reqA]);
    expect(managerB.requests, [reqB]);
  });
}

class SyncTestTopicEventTransport extends TopicEventTransport {
  final List<TopicEvent> replies = [];

  @override
  void onSend(TopicEvent event) => replies.add(event);

  void publishTestEvent(TopicEvent event) => onReceive(event);
}

class TestManager extends TopicManager {
  final Topic testDiscriminator;
  final List<TopicEvent> requests = [];

  TestManager(this.testDiscriminator);

  @override
  void handleEvent(TopicEvent event) {
    requests.add(event);
    sendEvent(event.cmd + testDiscriminator, event.payload + testDiscriminator);
  }

  @override
  Topic get topic => testDiscriminator;
}
