class UserModel {
  String? uid;
  String? email;
  String? fullname;
  String? profilePic;

  UserModel({this.uid, this.email, this.fullname, this.profilePic});
  UserModel.fromMap(Map<String, dynamic> data) {
    uid = data['uid'];
    email = data['email'];
    fullname = data['fullname'];
    profilePic = data['profilePic'];
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
      'profilePic': profilePic,
    };
  }
}
