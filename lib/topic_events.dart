library topic_events;

typedef Topic = String;

typedef Cmd = String;

typedef Payload = dynamic;

typedef Json = Map<String, dynamic>;

typedef EventHandler = void Function(TopicEvent);

class TopicEvent {
  final Topic topic;
  final Cmd cmd;
  final Payload payload;

  TopicEvent(this.topic, this.cmd, this.payload);

  TopicEvent.fromJson(Json json)
      : topic = json['topic'],
        cmd = json['cmd'],
        payload = json['payload'];

  Json toJson() => {
        'topic': topic,
        'cmd': cmd,
        'payload': payload,
      };

  @override
  bool operator ==(Object other) =>
      other is TopicEvent &&
      topic == other.topic &&
      cmd == other.cmd &&
      payload == other.payload;

  @override
  int get hashCode => topic.hashCode ^ cmd.hashCode ^ payload.hashCode;
}

abstract class TopicManager {
  Topic get topic;

  late EventHandler _onWrite;

  void handleEvent(TopicEvent event);

  void writeEvent(Cmd cmd, Payload data) =>
      _onWrite(TopicEvent(topic, cmd, data));
}

class TopicEventBroker {
  final _managers = <Topic, TopicManager>{};
  final TopicEventTransport _transport;

  TopicEventBroker(this._transport) {
    _transport._onIncoming = _dispatchEvent;
  }

  void listen() => _transport.onListen();

  void addManager(TopicManager manager) =>
      _managers[manager.topic] = manager.._onWrite = _transport.onOutgoing;

  void _dispatchEvent(TopicEvent event) =>
      _managers[event.topic]?.handleEvent(event);
}

abstract class TopicEventTransport {
  late EventHandler _onIncoming;

  void onIncoming(TopicEvent event) => _onIncoming(event);

  void onOutgoing(TopicEvent event);

  void onListen();
}
