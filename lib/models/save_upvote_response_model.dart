class SaveUpvoteResponseModel {
  bool status;
  String message;
  Result result;
  int errorCode;

  SaveUpvoteResponseModel(
      {this.status, this.message, this.result, this.errorCode});

  SaveUpvoteResponseModel.fromJson(Map<String, dynamic> json) {
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
  int svc;

  Result({this.svc});

  Result.fromJson(Map<String, dynamic> json) {
    svc = json['svc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['svc'] = this.svc;
    return data;
  }
}
