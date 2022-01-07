import 'model.dart';

typedef EventHandler = void Function(TopicEvent);

abstract class TopicManager {
  Topic get topic;

  late final EventHandler _onSend;

  void handleEvent(TopicEvent event);

  void sendEvent(Cmd cmd, Payload data) =>
      _onSend(TopicEvent(topic, cmd, data));
}

class TopicEventBroker {
  final _managers = <Topic, TopicManager>{};

  late final EventHandler _onSend;

  void setTransport(TopicEventTransport transport) {
    _onSend = transport.onSend;
    transport._handlers.add(_handleFromTransport);
  }

  void addManager(TopicManager manager) =>
      _managers[manager.topic] = manager.._onSend = _handleFromManager;

  void _handleFromTransport(TopicEvent event) =>
      _managers[event.topic]?.handleEvent(event);

  void _handleFromManager(TopicEvent event) => _onSend(event);
}

abstract class TopicEventTransport {
  final List<EventHandler> _handlers = [];

  void onReceive(TopicEvent event) =>
      _handlers.forEach((handler) => handler(event));

  void onSend(TopicEvent event);
}
