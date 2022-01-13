import 'model.dart';

typedef EventHandler = void Function(TopicEvent);

/// End consumer of [TopicEvent]s.
abstract class TopicManager {
  /// Used by [TopicEventBroker] for routing [TopicEvent]s to a [TopicManager] destination.
  /// Implementations must override this returning a unique string.
  Topic get topic;

  /// Implementations must override this to handle incoming [TopicEvent]s.
  void handleEvent(TopicEvent event);

  EventHandler? _onSend;

  /// Send [TopicEvent]s back to the the [TopicEventTransport] via the [TopicEventBroker].
  /// The [TopicManager]'s [topic] value is used.
  void sendEvent(Cmd cmd, Payload data) {
    _onSend!(TopicEvent(topic, cmd, data));
  }
}

/// A [TopicEventBroker] is used to route [TopicEvent]s
/// from a [TopicEventTransport] to [TopicManager] and vice versa.
class TopicEventBroker {
  final _managers = <Topic, TopicManager>{};

  TopicEventTransport? _transport;

  /// Set the [TopicEventTransport] to use. There can only be one transport per broker at a time.
  /// If a transport is already set, it will be replaced.
  /// The [TopicEventBroker] will automatically de-/register itself with the [TopicEventTransport].
  void setTransport(TopicEventTransport transport) {
    if (_transport == transport) return;
    if (_transport != null) {
      _transport!._handlers.remove(_handleFromTransport);
    }
    _transport = transport;
    transport._handlers.add(_handleFromTransport);
  }

  /// Register a [TopicManager] for handling [TopicEvent]s.
  /// Only one [TopicManager] may be registered for a given [Topic].
  void addManager(TopicManager manager) =>
      _managers[manager.topic] = manager.._onSend = _handleFromManager;

  void _handleFromTransport(TopicEvent event) =>
      _managers[event.topic]?.handleEvent(event);

  void _handleFromManager(TopicEvent event) => _transport?.onSend(event);
}

/// The [TopicEventTransport] is responsible for sending and receiving [TopicEvent]s.
abstract class TopicEventTransport {
  final Set<EventHandler> _handlers = {};

  /// Call this to forward a [TopicEvent] to all registered handlers.
  void onReceive(TopicEvent event) =>
      _handlers.forEach((handler) => handler(event));

  /// Override this to handle outgoing [TopicEvent]s.
  void onSend(TopicEvent event);
}
