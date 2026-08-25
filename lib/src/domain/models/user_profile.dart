class UserProfileModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? phoneNumber;

  const UserProfileModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
  });

  bool get hasPhoneLinked => phoneNumber != null && phoneNumber!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        uid: json['uid'] as String? ?? '',
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );
}
