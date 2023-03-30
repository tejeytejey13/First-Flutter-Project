class Post {
  final String time;
  final String post_id;
  final String postcontent;
  final String postimg;
  final String id;

  bool isLiked;

  Post({
    required this.time,
    required this.post_id,
    required this.postcontent,
    required this.postimg,
    required this.id,
    required this.isLiked,
  
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'post_id': post_id,
        'postcontent': postcontent,
        'postimg': postimg,
        'id' : id,
        'isLiked': isLiked,
      };

  static Post fromJson(Map<String, dynamic> json) => Post(
        time: json['time'],
        post_id: json['post_id'],
        postcontent: json['postcontent'],
        postimg: json['postimg'],
        id: json['id'],
        isLiked: json['isLiked'],
      );
}
