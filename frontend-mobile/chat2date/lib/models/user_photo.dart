// class UserPhoto {
//   final int id;
//   final String userId;
//   final Map<String, Object> attribute;

//   UserPhoto({required id,required this.userId, required this.attribute});

//   factory UserPhoto.fromJson(Map<String, dynamic> json) {
//     return UserPhoto(
//       id: json['id']
//       userId: json['user_userId'],
//       travelstyleId: json['travelstyle_travelId'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'user_userId': userId, 'travelstyle_travelId': travelstyleId};
//   }
// }