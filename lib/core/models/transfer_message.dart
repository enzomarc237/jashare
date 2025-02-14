enum MessageType {
  chunk,
  request,
  cancel,
  complete,
  error
}

class TransferMessage {
  final MessageType type;
  final String transferId;
  final Map<String, dynamic> data;

  TransferMessage({
    required this.type,
    required this.transferId,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'transferId': transferId,
      'data': data,
    };
  }

  factory TransferMessage.fromJson(Map<String, dynamic> json) {
    return TransferMessage(
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      transferId: json['transferId'],
      data: json['data'],
    );
  }
}