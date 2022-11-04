class UpvotesModelClass {
  bool status;
  bool message;
  List<Result> result;
  int errorCode;

  UpvotesModelClass({this.status, this.message, this.result, this.errorCode});

  UpvotesModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = [];
      json['result'].forEach((v) {
        result.add(new Result.fromJson(v));
      });
    }
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result.map((v) => v.toJson()).toList();
    }
    data['error_code'] = this.errorCode;
    return data;
  }
}

class Result {
  String id;
  String levelNameEn;
  String status;
  String levelNameAr;

  Result({this.id, this.levelNameEn, this.status, this.levelNameAr});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    levelNameEn = json['level_name_en'];
    status = json['status'];
    levelNameAr = json['level_name_ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['level_name_en'] = this.levelNameEn;
    data['status'] = this.status;
    data['level_name_ar'] = this.levelNameAr;
    return data;
  }
}
