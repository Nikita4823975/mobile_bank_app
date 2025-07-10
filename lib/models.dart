class User {
  final int userId;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String userType;
  final int? historyType;
  final double bonusBalance;
  final int roleId;

  User({
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.userType,
    this.historyType,
    required this.bonusBalance,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int? ?? 0,
      phoneNumber: json['phone_number'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'].toString().replaceFirst(' GMT', ''))
          : null,
      userType: json['user_type'] as String? ?? 'individual',
      historyType: json['history_type'] as int?,
      bonusBalance: double.tryParse(json['bonus_balance']?.toString() ?? '0') ?? 0.0,
      roleId: json['role_id'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate?.toIso8601String(),
        'user_type': userType,
        'history_type': historyType,
        'bonus_balance': bonusBalance,
        'role_id': roleId,
      };
}

class UserActivity {
  final int userId;
  final String firstName;
  final String lastName;
  final int totalTransactions;
  final double totalBalance;
  final double bonusBalance;

  UserActivity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.totalTransactions,
    required this.totalBalance,
    required this.bonusBalance,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return UserActivity(
      userId: parseInt(json['user_id']),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      totalTransactions: parseInt(json['total_transfers']),
      totalBalance: parseDouble(json['total_balance']),
      bonusBalance: parseDouble(json['bonus_balance']),
    );
  }
}



class Account {
  final int accountId;
  final String accountNumber;
  final int userId;
  final int typeId;
  final double balance;
  final DateTime openingDate;
  final bool isActive;
  final String? typeName;

  Account({
    required this.accountId,
    required this.accountNumber,
    required this.userId,
    required this.typeId,
    required this.balance,
    required this.openingDate,
    required this.isActive,
    this.typeName,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Account(
      accountId: json['account_id'] as int,
      accountNumber: json['account_number'] as String,
      userId: json['user_id'] as int,
      typeId: json['type_id'] as int,
      balance: parseDouble(json['balance']),
      openingDate: DateTime.parse(json['opening_date'] as String),
      isActive: (json['is_active'] == 1),
      typeName: json['type_name'] as String?,
    );
  }
}



class Transaction {
  final int transactionId;
  final String transactionUuid;
  final int? fromAccountId;
  final int? toAccountId;
  final double amount;
  final DateTime transactionDate;
  final int typeId;
  final String? recipientPhone;
  final int? categoryId;
  final String? categoryName;
  final String? fromAccount;
  final String? toAccount;
  final String? typeName;
  final bool isBonusPayment;

  Transaction({
    required this.transactionId,
    required this.transactionUuid,
    this.fromAccountId,
    this.toAccountId,
    required this.amount,
    required this.transactionDate,
    required this.typeId,
    this.recipientPhone,
    this.categoryId,
    this.categoryName,
    this.fromAccount,
    this.toAccount,
    this.typeName,
    this.isBonusPayment = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Transaction(
      transactionId: json['transaction_id'] as int,
      transactionUuid: json['transaction_uuid'] as String,
      fromAccountId: json['from_account_id'] as int?,
      toAccountId: json['to_account_id'] as int?,
      amount: parseDouble(json['amount']),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      typeId: json['type_id'] as int,
      recipientPhone: json['recipient_phone'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      fromAccount: json['from_account'] as String?,
      toAccount: json['to_account'] as String?,
      typeName: json['type_name'] as String?,
      isBonusPayment: (json['is_bonus_payment'] == 1),
    );
  }
}

class SupportMessage {
  final int messageId;
  final int userId;
  final int employeeId;
  final String messageText;
  final DateTime sendTime;
  final String senderType; // 'user' или 'support'

  SupportMessage({
    required this.messageId,
    required this.userId,
    required this.employeeId,
    required this.messageText,
    required this.sendTime,
    required this.senderType,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      messageId: json['message_id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as int? ?? 0,
      messageText: json['message_text'] as String,
      sendTime: DateTime.parse(json['send_time'] as String),
      senderType: json['sender_type'] as String,
    );
  }
}


class AirTicket {
  final int ticketId;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String? airline;
  final bool isAvailable;

  AirTicket({
    required this.ticketId,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.airline,
    required this.isAvailable,
  });

  factory AirTicket.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return AirTicket(
      ticketId: json['ticket_id'] as int,
      departureCity: json['departure_city'] as String,
      arrivalCity: json['arrival_city'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
      price: parseDouble(json['price']),
      airline: json['airline'] as String?,
      isAvailable: (json['is_available'] == 1),
    );
  }
}

class SupportTicket {
  final int ticketId;
  final int userId;
  final int? employeeId;
  final String subject;
  final String messageText;
  final String? replyText;
  final bool isRead;
  final bool isAnswered;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firstName;
  final String? lastName;

  SupportTicket({
    required this.ticketId,
    required this.userId,
    this.employeeId,
    required this.subject,
    required this.messageText,
    this.replyText,
    required this.isRead,
    required this.isAnswered,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticket_id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as int?,
      subject: json['subject'] as String,
      messageText: json['message_text'] as String,
      replyText: json['reply_text'] as String?,
      isRead: (json['is_read'] == 1),
      isAnswered: (json['is_answered'] == 1),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }
}
