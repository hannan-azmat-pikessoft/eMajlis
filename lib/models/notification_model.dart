class NotificationModel {
  bool status;
  String message;
  Result result;
  int errorCode;

  NotificationModel({this.status, this.message, this.result, this.errorCode});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    data['error_code'] = this.errorCode;
    return data;
  }
}

class Result {
  List<NotificationHistory> notificationHistory;
  String message;

  Result({this.notificationHistory, this.message});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['notification_history'] != null) {
      notificationHistory = [];
      json['notification_history'].forEach((v) {
        notificationHistory.add(new NotificationHistory.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notificationHistory != null) {
      data['notification_history'] =
          this.notificationHistory.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class NotificationHistory {
  String senderId;
  String senderName;
  String image;
  String title;
  String message;
  String type;
  String createdDate;
  String imageUrl;

  NotificationHistory(
      {this.senderId,
      this.senderName,
      this.image,
      this.title,
      this.message,
      this.type,
      this.createdDate,
      this.imageUrl});

  NotificationHistory.fromJson(Map<String, dynamic> json) {
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    image = json['image'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    createdDate = json['created_date'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender_id'] = this.senderId;
    data['sender_name'] = this.senderName;
    data['image'] = this.image;
    data['title'] = this.title;
    data['message'] = this.message;
    data['type'] = this.type;
    data['created_date'] = this.createdDate;
    data['image_url'] = this.imageUrl;
    return data;
  }
}
