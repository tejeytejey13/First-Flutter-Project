class Replies {
  final String time;
  final String reply_id;
  final String repcontent;
  final String repimg;

  bool isLiked;

  Replies({
    required this.time,
    required this.reply_id,
    required this.repcontent,
    required this.repimg,
    required this.isLiked,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'reply_id': reply_id,
        'postcontent': repcontent,
        'postimg': repimg,
        'isLiked': isLiked,
      };

  static Replies fromJson(Map<String, dynamic> json) => Replies(
        time: json['time'],
        reply_id: json['reply_id'],
        repcontent: json['repcontent'],
        repimg: json['repimg'],
        isLiked: json['isLiked'],
      );
}
