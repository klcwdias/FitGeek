class ResponseModel {
  final List<Choice> choices;

  ResponseModel({
    required this.choices,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    List<Choice> choicesList = [];
    if (json['choices'] != null) {
      choicesList = List<Choice>.from(
        json['choices'].map((choice) => Choice.fromJson(choice)),
      );
    }
    return ResponseModel(choices: choicesList);
  }
}

class Choice {
  final Message message;

  Choice({
    required this.message,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(message: Message.fromJson(json['message']));
  }
}

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }
}
