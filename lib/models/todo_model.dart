class TodoModel {
  final int? id;
  final String content;
  bool isDone;
  final DateTime createdAt;

  TodoModel({
    this.id,
    required this.content,
    this.isDone = false,
    required this.createdAt,
  });

  TodoModel.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        content = map['content'] as String,
        isDone = map['isDone'] as bool,
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'content': content,
        'isDone': isDone,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
