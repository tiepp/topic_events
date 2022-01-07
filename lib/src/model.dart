typedef Topic = String;

typedef Cmd = String;

typedef Payload = dynamic;

typedef Json = Map<String, dynamic>;

class TopicEvent {
  final Topic topic;
  final Cmd cmd;
  final Payload payload;

  const TopicEvent(this.topic, this.cmd, this.payload);

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
