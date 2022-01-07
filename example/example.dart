import 'dart:async';

import 'package:topic_events/topic_events.dart';

void main() {
  final socket = AnimalSocket();

  TopicEventBroker()
    ..addManager(CatManager())
    ..addManager(DogManager())
    ..setTransport(socket);

  socket.connect();
  socket.events
      .add(TopicEvent(topicCat, cmdSay, 'something')); // "meow something"
  socket.events
      .add(TopicEvent(topicDog, cmdSay, 'anything')); // "woof anything"
}

class AnimalSocket extends TopicEventTransport {
  @override
  void onSend(TopicEvent event) {
    if (event.cmd == cmdPrint) print(event.payload);
  }

  final events = StreamController<TopicEvent>();

  void connect() => events.stream.listen(onReceive);
}

class CatManager extends TopicManager {
  @override
  Topic get topic => topicCat;

  @override
  void handleEvent(TopicEvent event) {
    if (event.cmd == cmdSay) {
      sendEvent(cmdPrint, 'meow ${event.payload}');
    }
  }
}

class DogManager extends TopicManager {
  @override
  Topic get topic => topicDog;

  @override
  void handleEvent(TopicEvent event) {
    if (event.cmd == cmdSay) {
      sendEvent(cmdPrint, 'woof ${event.payload}');
    }
  }
}

const topicCat = 'cat', topicDog = 'dog', cmdSay = 'say', cmdPrint = 'print';
