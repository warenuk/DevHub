import 'package:equatable/equatable.dart';

/// Domain representation of a Firebase Cloud Messaging push notification.
class PushMessage extends Equatable {
  const PushMessage({
    this.title,
    this.body,
    this.imageUrl,
    this.link,
    this.category,
    this.collapseKey,
    this.from,
    this.messageId,
    this.sentTime,
    this.data = const <String, dynamic>{},
  });

  final String? title;
  final String? body;
  final String? imageUrl;
  final Uri? link;
  final String? category;
  final String? collapseKey;
  final String? from;
  final String? messageId;
  final DateTime? sentTime;
  final Map<String, dynamic> data;

  PushMessage copyWith({
    String? title,
    String? body,
    String? imageUrl,
    Uri? link,
    String? category,
    String? collapseKey,
    String? from,
    String? messageId,
    DateTime? sentTime,
    Map<String, dynamic>? data,
  }) {
    return PushMessage(
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      category: category ?? this.category,
      collapseKey: collapseKey ?? this.collapseKey,
      from: from ?? this.from,
      messageId: messageId ?? this.messageId,
      sentTime: sentTime ?? this.sentTime,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    body,
    imageUrl,
    link,
    category,
    collapseKey,
    from,
    messageId,
    sentTime,
    data,
  ];
}
