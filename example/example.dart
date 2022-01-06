import 'dart:async';

import 'package:topic_events/topic_events.dart';

void main() {
  final socket = AnimalSocket();

  TopicEventBroker(socket)
    ..addManager(CatManager())
    ..addManager(DogManager())
    ..listen();

  socket.publish(TopicEvent(topicCat, cmdSay, 'something')); // "meow something"
  socket.publish(TopicEvent(topicDog, cmdSay, 'anything')); // "woof anything"
}

class AnimalSocket extends TopicEventTransport {
  final events = StreamController<TopicEvent>();

  @override
  void onListen() => events.stream.listen(onIncoming);

  @override
  void onOutgoing(TopicEvent event) {
    if (event.cmd == cmdPrint) {
      print(event.payload);
    }
  }

  void publish(TopicEvent topicEvent) => events.add(topicEvent);
}

class CatManager extends TopicManager {
  @override
  Topic get topic => topicCat;

  @override
  void handleEvent(TopicEvent event) {
    if (event.cmd == cmdSay) {
      writeEvent(cmdPrint, 'meow ${event.payload}');
    }
  }
}

class DogManager extends TopicManager {
  @override
  Topic get topic => topicDog;

  @override
  void handleEvent(TopicEvent event) {
    if (event.cmd == cmdSay) {
      writeEvent(cmdPrint, 'woof ${event.payload}');
    }
  }
}

const topicCat = 'cat', topicDog = 'dog', cmdSay = 'say', cmdPrint = 'print';
