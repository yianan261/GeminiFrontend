class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool accessLocationAllowed;
  final bool notificationAllowed;
  final bool googleTakeoutUploaded;
  final bool interestSelected;
  final bool onboardingCompleted;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.accessLocationAllowed,
    required this.notificationAllowed,
    required this.googleTakeoutUploaded,
    required this.interestSelected,
    required this.onboardingCompleted,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'accessLocationAllowed': accessLocationAllowed,
    'notificationAllowed': notificationAllowed,
    'googleTakeoutUploaded': googleTakeoutUploaded,
    'interestSelected': interestSelected,
    'onboardingCompleted': onboardingCompleted,
  };
}
