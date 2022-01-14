import 'package:test/test.dart';
import 'package:topic_events/topic_events.dart';

void main() {
  const topicA = 'A';
  const topicB = 'B';
  const topicX = 'X';

  final inA = TopicEvent(topicA, 'abc', 'def');
  final inB = TopicEvent(topicB, 'ghi', 'jkl');
  final inX = TopicEvent(topicX, 'mno', 'pqr');

  final outA = TopicEvent(inA.topic, inA.cmd + topicA, inA.payload + topicA);
  final outB = TopicEvent(inB.topic, inB.cmd + topicB, inB.payload + topicB);
  final outX = TopicEvent(inX.topic, inX.cmd + topicX, inX.payload + topicX);

  var transportA;
  var transportB;
  var managerA;
  var managerB;
  var managerX;
  var brokerA;
  var brokerB;

  setUp(() {
    transportA = SyncTestTopicEventTransport();
    transportB = SyncTestTopicEventTransport();
    managerA = TestManager(topicA);
    managerB = TestManager(topicB);
    managerX = TestManager(topicX);
    brokerA = TopicEventBroker();
    brokerB = TopicEventBroker();

    expect(transportA.replies, isEmpty);
    expect(transportB.replies, isEmpty);
    expect(managerA.requests, isEmpty);
    expect(managerB.requests, isEmpty);
    expect(managerX.requests, isEmpty);
  });

  test('static config', () {
    brokerA
      ..addManager(managerA)
      ..addManager(managerB)
      ..setTransport(transportA);

    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);

    transportA.publishTestEvent(inX);

    expect(transportA.replies, [outA]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);

    transportA.publishTestEvent(inB);

    expect(transportA.replies, [outA, outB]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, [inB]);
  });

  test('dynamic config manager', () {
    brokerA
      ..addManager(managerA)
      ..setTransport(transportA);

    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);
    expect(managerX.requests, isEmpty);

    transportA.publishTestEvent(inB);

    expect(transportA.replies, [outA]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);
    expect(managerX.requests, isEmpty);

    brokerA.addManager(managerB);
    transportA.publishTestEvent(inB);

    expect(transportA.replies, [outA, outB]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, [inB]);
    expect(managerX.requests, isEmpty);

    brokerA.addManager(managerX);
    transportA.publishTestEvent(inX);

    expect(transportA.replies, [outA, outB, outX]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, [inB]);
    expect(managerX.requests, [inX]);
  });

  test('dynamic config transport', () {
    brokerA
      ..addManager(managerA)
      ..addManager(managerB)
      ..setTransport(transportA);

    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA]);
    expect(transportB.replies, isEmpty);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);

    transportB.publishTestEvent(inB);

    expect(transportA.replies, [outA]);
    expect(transportB.replies, isEmpty);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);

    brokerA.setTransport(transportB);
    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA]);
    expect(transportB.replies, isEmpty);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, isEmpty);

    transportB.publishTestEvent(inB);

    expect(transportA.replies, [outA]);
    expect(transportB.replies, [outB]);
    expect(managerA.requests, [inA]);
    expect(managerB.requests, [inB]);
  });

  test('dynamic config broker', () {
    final managerAA = TestManager(topicA);
    final brokerAA = TopicEventBroker()..addManager(managerAA);

    brokerA.addManager(managerA);

    transportA.publishTestEvent(inA);

    expect(managerAA.requests, isEmpty);

    brokerA.setTransport(transportA);
    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA]);
    expect(managerA.requests, [inA]);
    expect(managerAA.requests, isEmpty);

    brokerAA.setTransport(transportA);
    transportA.publishTestEvent(inA);

    expect(transportA.replies, [outA, outA, outA]);
    expect(managerA.requests, [inA, inA]);
    expect(managerAA.requests, [inA]);
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
