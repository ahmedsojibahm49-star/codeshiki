/// Plain data models. NO Hive annotations — models are stored as plain
/// `Map<String, dynamic>` (Hive supports maps natively) via [fromJson]/[toJson].
/// Keep field names stable: feature builders and Hive persistence depend on them.
library;

// ---------------------------------------------------------------------------
// Courses
// ---------------------------------------------------------------------------

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    this.instructorPhoto = '',
    required this.category,
    required this.access, // 'free' | 'pro' | 'paid'
    required this.price, // 0 if free; BDT (taka)
    this.oldPrice = 0,
    required this.rating,
    required this.ratingCount,
    required this.students,
    required this.lessonsCount,
    required this.hours,
    required this.coverPhoto, // asset path
    required this.description,
    this.modules = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        instructor: json['instructor'] as String,
        instructorPhoto: json['instructorPhoto'] as String? ?? '',
        category: json['category'] as String,
        access: json['access'] as String,
        price: (json['price'] as num).toInt(),
        oldPrice: (json['oldPrice'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num).toDouble(),
        ratingCount: (json['ratingCount'] as num).toInt(),
        students: (json['students'] as num).toInt(),
        lessonsCount: (json['lessonsCount'] as num).toInt(),
        hours: (json['hours'] as num).toDouble(),
        coverPhoto: json['coverPhoto'] as String,
        description: json['description'] as String,
        modules: (json['modules'] as List<dynamic>? ?? [])
            .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String id;
  final String title;
  final String instructor;
  final String instructorPhoto;
  final String category;
  final String access;
  final int price;
  final int oldPrice;
  final double rating;
  final int ratingCount;
  final int students;
  final int lessonsCount;
  final double hours;
  final String coverPhoto;
  final String description;
  final List<Module> modules;

  bool get isFree => access == 'free';
  bool get isPro => access == 'pro';
  bool get isPaid => access == 'paid';

  /// All lessons across modules, in order.
  List<Lesson> get allLessons =>
      modules.expand((m) => m.lessons).toList(growable: false);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructor': instructor,
        'instructorPhoto': instructorPhoto,
        'category': category,
        'access': access,
        'price': price,
        'oldPrice': oldPrice,
        'rating': rating,
        'ratingCount': ratingCount,
        'students': students,
        'lessonsCount': lessonsCount,
        'hours': hours,
        'coverPhoto': coverPhoto,
        'description': description,
        'modules': modules.map((m) => m.toJson()).toList(),
      };
}

class Module {
  const Module({
    required this.id,
    required this.title,
    this.lessons = const [],
  });

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        title: json['title'] as String,
        lessons: (json['lessons'] as List<dynamic>? ?? [])
            .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String id;
  final String title;
  final List<Lesson> lessons;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.type, // 'video' | 'reading' | 'quiz' | 'code'
    required this.durationMin,
    this.videoUrl = '',
    this.locked = false,
    this.description = '',
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        durationMin: (json['durationMin'] as num).toInt(),
        videoUrl: json['videoUrl'] as String? ?? '',
        locked: json['locked'] as bool? ?? false,
        description: json['description'] as String? ?? '',
      );

  final String id;
  final String title;
  final String type;
  final int durationMin;
  final String videoUrl;
  final bool locked;
  final String description;

  bool get isVideo => type == 'video';
  bool get isQuiz => type == 'quiz';
  bool get isCode => type == 'code';
  bool get isReading => type == 'reading';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'durationMin': durationMin,
        'videoUrl': videoUrl,
        'locked': locked,
        'description': description,
      };
}

// ---------------------------------------------------------------------------
// User
// ---------------------------------------------------------------------------

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.avatarPhoto = '',
    this.bio = '',
    this.goal = '',
    this.level = 1,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        email: json['email'] as String,
        avatarPhoto: json['avatarPhoto'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        level: (json['level'] as num?)?.toInt() ?? 1,
      );

  final String name;
  final String email;
  final String avatarPhoto;
  final String bio;
  final String goal;
  final int level;

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarPhoto,
    String? bio,
    String? goal,
    int? level,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        avatarPhoto: avatarPhoto ?? this.avatarPhoto,
        bio: bio ?? this.bio,
        goal: goal ?? this.goal,
        level: level ?? this.level,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarPhoto': avatarPhoto,
        'bio': bio,
        'goal': goal,
        'level': level,
      };
}

// ---------------------------------------------------------------------------
// Forum
// ---------------------------------------------------------------------------

class ForumQuestion {
  const ForumQuestion({
    required this.id,
    required this.authorName,
    this.authorPhoto = '',
    required this.title,
    required this.body,
    this.tags = const [],
    this.upvotes = 0,
    this.answersCount = 0,
    required this.createdLabel,
    this.accepted = false,
    this.answers = const [],
  });

  factory ForumQuestion.fromJson(Map<String, dynamic> json) =>
      ForumQuestion(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        authorPhoto: json['authorPhoto'] as String? ?? '',
        title: json['title'] as String,
        body: json['body'] as String,
        tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
        upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
        answersCount: (json['answersCount'] as num?)?.toInt() ?? 0,
        createdLabel: json['createdLabel'] as String,
        accepted: json['accepted'] as bool? ?? false,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) =>
                ForumAnswer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String id;
  final String authorName;
  final String authorPhoto;
  final String title;
  final String body;
  final List<String> tags;
  final int upvotes;
  final int answersCount;
  final String createdLabel;
  final bool accepted;
  final List<ForumAnswer> answers;

  ForumQuestion copyWith({
    int? upvotes,
    int? answersCount,
    bool? accepted,
    List<ForumAnswer>? answers,
  }) =>
      ForumQuestion(
        id: id,
        authorName: authorName,
        authorPhoto: authorPhoto,
        title: title,
        body: body,
        tags: tags,
        upvotes: upvotes ?? this.upvotes,
        answersCount: answersCount ?? this.answersCount,
        createdLabel: createdLabel,
        accepted: accepted ?? this.accepted,
        answers: answers ?? this.answers,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'title': title,
        'body': body,
        'tags': tags,
        'upvotes': upvotes,
        'answersCount': answersCount,
        'createdLabel': createdLabel,
        'accepted': accepted,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

class ForumAnswer {
  const ForumAnswer({
    required this.id,
    required this.authorName,
    this.authorPhoto = '',
    required this.body,
    this.upvotes = 0,
    this.accepted = false,
  });

  factory ForumAnswer.fromJson(Map<String, dynamic> json) => ForumAnswer(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        authorPhoto: json['authorPhoto'] as String? ?? '',
        body: json['body'] as String,
        upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
        accepted: json['accepted'] as bool? ?? false,
      );

  final String id;
  final String authorName;
  final String authorPhoto;
  final String body;
  final int upvotes;
  final bool accepted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'body': body,
        'upvotes': upvotes,
        'accepted': accepted,
      };
}

// ---------------------------------------------------------------------------
// Notifications / Orders / Badges / Leaderboard / Reviews / Coupons
// ---------------------------------------------------------------------------

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timeLabel: json['timeLabel'] as String,
        type: json['type'] as String,
        read: json['read'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final String type; // 'lesson' | 'streak' | 'reply' | 'certificate' |
  // 'payment' | 'course' | 'reminder' | 'achievement'
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        timeLabel: timeLabel,
        type: type,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timeLabel': timeLabel,
        'type': type,
        'read': read,
      };
}

class Order {
  const Order({
    required this.id,
    required this.courseTitle,
    required this.amount,
    required this.dateLabel,
    required this.status, // 'Paid' | 'Free' | 'Pending' | 'Failed'
    required this.invoiceNo,
    required this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        courseTitle: json['courseTitle'] as String,
        amount: (json['amount'] as num).toInt(),
        dateLabel: json['dateLabel'] as String,
        status: json['status'] as String,
        invoiceNo: json['invoiceNo'] as String,
        paymentMethod: json['paymentMethod'] as String,
      );

  final String id;
  final String courseTitle;
  final int amount; // BDT (taka)
  final String dateLabel;
  final String status;
  final String invoiceNo;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseTitle': courseTitle,
        'amount': amount,
        'dateLabel': dateLabel,
        'status': status,
        'invoiceNo': invoiceNo,
        'paymentMethod': paymentMethod,
      };
}

class BadgeInfo {
  const BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    this.unlocked = false,
  });

  factory BadgeInfo.fromJson(Map<String, dynamic> json) => BadgeInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        assetPath: json['assetPath'] as String,
        unlocked: json['unlocked'] as bool? ?? false,
      );

  final String id;
  final String name;
  final String description;
  final String assetPath; // assets/badges/*.png
  final bool unlocked;

  BadgeInfo copyWith({bool? unlocked}) => BadgeInfo(
        id: id,
        name: name,
        description: description,
        assetPath: assetPath,
        unlocked: unlocked ?? this.unlocked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'assetPath': assetPath,
        'unlocked': unlocked,
      };
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.photo,
    required this.xp,
    required this.rank,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        name: json['name'] as String,
        photo: json['photo'] as String,
        xp: (json['xp'] as num).toInt(),
        rank: (json['rank'] as num).toInt(),
        isMe: json['isMe'] as bool? ?? false,
      );

  final String name;
  final String photo;
  final int xp;
  final int rank;
  final bool isMe;

  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': photo,
        'xp': xp,
        'rank': rank,
        'isMe': isMe,
      };
}

class Review {
  const Review({
    required this.authorName,
    required this.authorPhoto,
    required this.rating,
    required this.text,
    required this.timeLabel,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        authorName: json['authorName'] as String,
        authorPhoto: json['authorPhoto'] as String,
        rating: (json['rating'] as num).toDouble(),
        text: json['text'] as String,
        timeLabel: json['timeLabel'] as String,
      );

  final String authorName;
  final String authorPhoto;
  final double rating;
  final String text;
  final String timeLabel;

  Map<String, dynamic> toJson() => {
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'rating': rating,
        'text': text,
        'timeLabel': timeLabel,
      };
}

class Coupon {
  const Coupon({
    required this.code,
    required this.description,
    required this.discountLabel,
    this.flatAmount = 0,
    this.percent = 0,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        code: json['code'] as String,
        description: json['description'] as String,
        discountLabel: json['discountLabel'] as String,
        flatAmount: (json['flatAmount'] as num?)?.toInt() ?? 0,
        percent: (json['percent'] as num?)?.toInt() ?? 0,
      );

  final String code;
  final String description;
  final String discountLabel;
  final int flatAmount; // BDT off, 0 when percent-based
  final int percent; // % off, 0 when flat-based

  /// Price after applying this coupon to [price].
  int applyTo(int price) {
    if (flatAmount > 0) return (price - flatAmount).clamp(0, price);
    if (percent > 0) return (price * (100 - percent) / 100).round();
    return price;
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'discountLabel': discountLabel,
        'flatAmount': flatAmount,
        'percent': percent,
      };
}

// ---------------------------------------------------------------------------
// Code projects
// ---------------------------------------------------------------------------

class CodeProject {
  const CodeProject({
    required this.id,
    required this.title,
    required this.language,
    this.files = const [],
    required this.lastEdited,
    this.runOutput = '',
    this.tests = const [],
  });

  factory CodeProject.fromJson(Map<String, dynamic> json) => CodeProject(
        id: json['id'] as String,
        title: json['title'] as String,
        language: json['language'] as String,
        files: (json['files'] as List<dynamic>? ?? [])
            .map((e) =>
                ProjectFile.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        lastEdited: json['lastEdited'] as String,
        runOutput: json['runOutput'] as String? ?? '',
        tests: (json['tests'] as List<dynamic>? ?? [])
            .map((e) => CodeTestResult.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String id;
  final String title;
  final String language;
  final List<ProjectFile> files;
  final String lastEdited;
  final String runOutput; // canned demo output shown after "Run"
  final List<CodeTestResult> tests; // canned pass/fail rows

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'language': language,
        'files': files.map((f) => f.toJson()).toList(),
        'lastEdited': lastEdited,
        'runOutput': runOutput,
        'tests': tests.map((t) => t.toJson()).toList(),
      };
}

class ProjectFile {
  const ProjectFile({required this.name, required this.content});

  factory ProjectFile.fromJson(Map<String, dynamic> json) => ProjectFile(
        name: json['name'] as String,
        content: json['content'] as String,
      );

  final String name;
  final String content;

  Map<String, dynamic> toJson() => {'name': name, 'content': content};
}

class CodeTestResult {
  const CodeTestResult({required this.name, required this.passed});

  factory CodeTestResult.fromJson(Map<String, dynamic> json) =>
      CodeTestResult(
        name: json['name'] as String,
        passed: json['passed'] as bool,
      );

  final String name;
  final bool passed;

  Map<String, dynamic> toJson() => {'name': name, 'passed': passed};
}
