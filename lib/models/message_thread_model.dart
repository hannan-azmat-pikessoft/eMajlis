class MessageThreadModel {
  final messageId;
  final String threadName;
  final int myMemberId;
  final int otherMemberId;
  final String memberName;
  final String imageUrl;
  final int unseenMessages;
  final String lastMessage;
  final DateTime lastMessageDate;

  MessageThreadModel(
    this.messageId,
    this.threadName,
    this.myMemberId,
    this.otherMemberId,
    this.memberName,
    this.imageUrl,
    this.unseenMessages,
    this.lastMessage,
    this.lastMessageDate,
  );
}
