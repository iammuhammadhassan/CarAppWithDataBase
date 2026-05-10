class Message {
  final int id;
  final int inquiryId;
  final int senderId;
  final String messageText;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.inquiryId,
    required this.senderId,
    required this.messageText,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id:
          int.tryParse(
            json['id']?.toString() ?? json['message_id']?.toString() ?? '0',
          ) ??
          0,
      inquiryId: int.tryParse(json['inquiry_id']?.toString() ?? '0') ?? 0,
      senderId: int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      messageText:
          json['message_text']?.toString() ?? json['message']?.toString() ?? '',
      sentAt:
          DateTime.tryParse(
            json['sent_at']?.toString() ?? json['created_at']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
