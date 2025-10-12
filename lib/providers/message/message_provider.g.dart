// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatMessagesNotifier)
const chatMessagesProvider = ChatMessagesNotifierFamily._();

final class ChatMessagesNotifierProvider
    extends $AsyncNotifierProvider<ChatMessagesNotifier, List<Message>> {
  const ChatMessagesNotifierProvider._({
    required ChatMessagesNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'chatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesNotifierHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatMessagesNotifier create() => ChatMessagesNotifier();

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesNotifierHash() =>
    r'2c5c49cd5b31350a194e34f239a81430ab80e534';

final class ChatMessagesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatMessagesNotifier,
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>,
          int
        > {
  const ChatMessagesNotifierFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatMessagesNotifierProvider call(int chatId) =>
      ChatMessagesNotifierProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

abstract class _$ChatMessagesNotifier extends $AsyncNotifier<List<Message>> {
  late final _$args = ref.$arg as int;
  int get chatId => _$args;

  FutureOr<List<Message>> build(int chatId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Message>>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>>, List<Message>>,
              AsyncValue<List<Message>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
