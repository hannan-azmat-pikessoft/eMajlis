class SVCScoreModelClass {
  bool status;
  String message;
  Result result;
  int errorCode;

  SVCScoreModelClass({this.status, this.message, this.result, this.errorCode});

  SVCScoreModelClass.fromJson(Map<String, dynamic> json) {
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
  List<Svc> svc;
  List<UpvoteScore> upvoteScore;

  Result({this.svc, this.upvoteScore});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['svc'] != null) {
      svc = [];
      json['svc'].forEach((v) {
        svc.add(new Svc.fromJson(v));
      });
    }
    if (json['upvote_score'] != null) {
      upvoteScore = [];
      json['upvote_score'].forEach((v) {
        upvoteScore.add(new UpvoteScore.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.svc != null) {
      data['svc'] = this.svc.map((v) => v.toJson()).toList();
    }
    if (this.upvoteScore != null) {
      data['upvote_score'] = this.upvoteScore.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Svc {
  String creditScore;

  Svc({this.creditScore});

  Svc.fromJson(Map<String, dynamic> json) {
    creditScore = json['credit_score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['credit_score'] = this.creditScore;
    return data;
  }
}

class UpvoteScore {
  String upvotes;
  String levelNameEn;

  UpvoteScore({this.upvotes, this.levelNameEn});

  UpvoteScore.fromJson(Map<String, dynamic> json) {
    upvotes = json['upvotes'];
    levelNameEn = json['level_name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upvotes'] = this.upvotes;
    data['level_name_en'] = this.levelNameEn;
    return data;
  }
}
