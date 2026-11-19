import 'code_samples.dart';
import 'models.dart';

/// Static demo content for the CodeShikhi demo app. All data is local —
/// no network, no backend. Providers read from here and persist user state
/// (enrollments, wallet, forum, ...) to Hive.
class DemoData {
  DemoData._();

  // ---------------------------------------------------------------------------
  // Demo user
  // ---------------------------------------------------------------------------

  static const UserProfile me = UserProfile(
    name: 'Rahim Uddin',
    email: 'demo@codeshikhi.app',
    avatarPhoto: 'assets/photos/person-male-park.jpg',
    bio: 'CS student from Dhaka. Learning web development one lesson a day.',
    goal: 'Become a full-stack developer',
    level: 7,
  );

  static const int demoXp = 1240;
  static const int demoVolts = 320;
  static const int demoStreakDays = 12;
  static const int demoLevel = 7;

  static const String demoEmail = 'demo@codeshikhi.app';
  static const String demoPassword = 'demo1234';

  // ---------------------------------------------------------------------------
  // Demo videos (Google sample bucket — public sample MP4s)
  // ---------------------------------------------------------------------------

  static const List<String> sampleVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ];

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  static const List<String> categories = [
    'Web Dev',
    'Python',
    'Java',
    'DSA',
    'UI/UX',
    'Flutter',
  ];

  // ---------------------------------------------------------------------------
  // Courses
  // ---------------------------------------------------------------------------

  static final List<Course> courses = [
    _reactCourse(),
    _pythonCourse(),
    _mernCourse(),
    _dsaCourse(),
  ];

  static Course? courseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Lesson? lessonById(String courseId, String lessonId) {
    final course = courseById(courseId);
    if (course == null) return null;
    for (final lesson in course.allLessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  static int _videoIndex = 0;

  static String _nextVideo() {
    final url = sampleVideos[_videoIndex % sampleVideos.length];
    _videoIndex++;
    return url;
  }

  static Lesson _v(
    String id,
    String title,
    int mins, {
    bool locked = false,
    String description = '',
  }) =>
      Lesson(
        id: id,
        title: title,
        type: 'video',
        durationMin: mins,
        videoUrl: _nextVideo(),
        locked: locked,
        description: description,
      );

  static Lesson _r(String id, String title, int mins, {bool locked = false}) =>
      Lesson(
        id: id,
        title: title,
        type: 'reading',
        durationMin: mins,
        locked: locked,
      );

  static Lesson _q(String id, String title, int mins, {bool locked = false}) =>
      Lesson(
        id: id,
        title: title,
        type: 'quiz',
        durationMin: mins,
        locked: locked,
      );

  static Lesson _c(String id, String title, int mins, {bool locked = false}) =>
      Lesson(
        id: id,
        title: title,
        type: 'code',
        durationMin: mins,
        locked: locked,
      );

  static Course _reactCourse() => Course(
        id: 'react-js-zero',
        title: 'React JS from Zero',
        instructor: 'Nusrat Jahan',
        instructorPhoto: 'assets/photos/person-female-hijab.jpg',
        category: 'Web Dev',
        access: 'paid',
        price: 1500,
        oldPrice: 2500,
        rating: 4.8,
        ratingCount: 1243,
        students: 8420,
        lessonsCount: 10,
        hours: 6.5,
        coverPhoto: 'assets/photos/scene-reading.jpg',
        description:
            'React শিখুন একদম শূন্য থেকে — components, hooks, state আর routing, বাংলায় ধাপে ধাপে। শেষে নিজের portfolio প্রজেক্ট বানাবেন।',
        modules: [
          Module(
            id: 'react-m1',
            title: 'Getting Started',
            lessons: [
              _v('react-js-zero-m1-l1', 'Welcome to React', 8,
                  description: 'What React is and why it matters.'),
              _v('react-js-zero-m1-l2', 'Setting Up Your Environment', 12,
                  locked: true),
              _r('react-js-zero-m1-l3', 'Reading: How React Renders', 6,
                  locked: true),
              _q('react-js-zero-m1-l4', 'Quiz: React Basics', 5, locked: true),
            ],
          ),
          Module(
            id: 'react-m2',
            title: 'Components & Props',
            lessons: [
              _v('react-js-zero-m2-l1', 'Your First Component', 14,
                  locked: true),
              _v('react-js-zero-m2-l2', 'Props & Composition', 16,
                  locked: true),
              _c('react-js-zero-m2-l3', 'Code: Build a Card Component', 20,
                  locked: true),
            ],
          ),
          Module(
            id: 'react-m3',
            title: 'State & Hooks',
            lessons: [
              _v('react-js-zero-m3-l1', 'useState Deep Dive', 18,
                  locked: true),
              _v('react-js-zero-m3-l2', 'useEffect & Data Fetching', 15,
                  locked: true),
              _q('react-js-zero-m3-l3', 'Final Quiz: Hooks', 10,
                  locked: true),
            ],
          ),
        ],
      );

  static Course _pythonCourse() => Course(
        id: 'python-one-night',
        title: 'Python in One Night',
        instructor: 'Tanvir Hasan',
        instructorPhoto: 'assets/photos/person-male-glasses.jpg',
        category: 'Python',
        access: 'free',
        price: 0,
        rating: 4.9,
        ratingCount: 3210,
        students: 21400,
        lessonsCount: 10,
        hours: 4.0,
        coverPhoto: 'assets/photos/dhaka-students-group.jpg',
        description:
            'এক রাতেই Python-এর ভিত্তি — variables, loops, functions আর ছোট ছোট প্রজেক্ট। সম্পূর্ণ ফ্রি, বাংলায়।',
        modules: [
          Module(
            id: 'python-m1',
            title: 'Python Basics',
            lessons: [
              _v('python-one-night-m1-l1', 'Why Python?', 7,
                  description: 'Python দিয়ে কী কী বানানো যায়।'),
              _v('python-one-night-m1-l2', 'Variables & Data Types', 11),
              _r('python-one-night-m1-l3', 'Reading: Naming Things Well', 5),
              _q('python-one-night-m1-l4', 'Quiz: Basics', 5),
            ],
          ),
          Module(
            id: 'python-m2',
            title: 'Control Flow',
            lessons: [
              _v('python-one-night-m2-l1', 'If, Else & Logic', 12),
              _v('python-one-night-m2-l2', 'Loops That Work for You', 13),
              _c('python-one-night-m2-l3', 'Code: Guess the Number', 18),
            ],
          ),
          Module(
            id: 'python-m3',
            title: 'Functions & Files',
            lessons: [
              _v('python-one-night-m3-l1', 'Writing Functions', 14),
              _v('python-one-night-m3-l2', 'Lists, Dicts & Files', 16),
              _q('python-one-night-m3-l3', 'Final Quiz', 8),
            ],
          ),
        ],
      );

  static Course _mernCourse() => Course(
        id: 'mern-project-camp',
        title: 'Full-Stack MERN Project Camp',
        instructor: 'Maliha Akter',
        instructorPhoto: 'assets/photos/person-female-curly.jpg',
        category: 'Web Dev',
        access: 'pro',
        price: 0,
        rating: 4.9,
        ratingCount: 864,
        students: 3120,
        lessonsCount: 11,
        hours: 12.0,
        coverPhoto: 'assets/photos/scene-coffee.jpg',
        description:
            'MongoDB, Express, React আর Node দিয়ে একটা সম্পূর্ণ প্রজেক্ট বানান — auth, payments আর deploy সহ। শুধু Pro সদস্যদের জন্য।',
        modules: [
          Module(
            id: 'mern-m1',
            title: 'Project Setup',
            lessons: [
              _v('mern-project-camp-m1-l1', 'Camp Overview & Final Project', 9,
                  description: 'যা যা বানাবেন, এক নজরে।'),
              _v('mern-project-camp-m1-l2', 'Setting Up the Monorepo', 14,
                  locked: true),
              _r('mern-project-camp-m1-l3', 'Reading: MERN Architecture', 8,
                  locked: true),
              _q('mern-project-camp-m1-l4', 'Quiz: Architecture', 5,
                  locked: true),
            ],
          ),
          Module(
            id: 'mern-m2',
            title: 'Backend with Node & MongoDB',
            lessons: [
              _v('mern-project-camp-m2-l1', 'Express APIs from Scratch', 20,
                  locked: true),
              _v('mern-project-camp-m2-l2', 'MongoDB Models & Auth', 22,
                  locked: true),
              _c('mern-project-camp-m2-l3', 'Code: JWT Login Endpoint', 25,
                  locked: true),
            ],
          ),
          Module(
            id: 'mern-m3',
            title: 'Frontend & Deploy',
            lessons: [
              _v('mern-project-camp-m3-l1', 'Connecting React to the API', 18,
                  locked: true),
              _v('mern-project-camp-m3-l2', 'Payments with bKash', 16,
                  locked: true),
              _v('mern-project-camp-m3-l3', 'Deploy to Production', 14,
                  locked: true),
              _q('mern-project-camp-m3-l4', 'Final Quiz', 10, locked: true),
            ],
          ),
        ],
      );

  static Course _dsaCourse() => Course(
        id: 'dsa-java',
        title: 'DSA with Java',
        instructor: 'Sakib Al Amin',
        instructorPhoto: 'assets/photos/person-male-cap.jpg',
        category: 'DSA',
        access: 'paid',
        price: 1500,
        oldPrice: 2000,
        rating: 4.7,
        ratingCount: 689,
        students: 4280,
        lessonsCount: 10,
        hours: 9.0,
        coverPhoto: 'assets/photos/dhaka-student-male.jpg',
        description:
            'Data Structures & Algorithms — arrays থেকে graphs পর্যন্ত, Java দিয়ে। ইন্টারভিউ প্রস্তুতির জন্য ১০০+ সমস্যা।',
        modules: [
          Module(
            id: 'dsa-m1',
            title: 'Big-O & Arrays',
            lessons: [
              _v('dsa-java-m1-l1', 'Why DSA Matters', 10,
                  description: 'ইন্টারভিউতে DSA কেন জিজ্ঞেস করা হয়।'),
              _v('dsa-java-m1-l2', 'Big-O Notation, Simply', 13, locked: true),
              _r('dsa-java-m1-l3', 'Reading: Array Patterns', 7, locked: true),
              _q('dsa-java-m1-l4', 'Quiz: Complexity', 6, locked: true),
            ],
          ),
          Module(
            id: 'dsa-m2',
            title: 'Stacks, Queues & Linked Lists',
            lessons: [
              _v('dsa-java-m2-l1', 'Stacks & Queues in Java', 15,
                  locked: true),
              _v('dsa-java-m2-l2', 'Linked Lists Visualized', 17,
                  locked: true),
              _c('dsa-java-m2-l3', 'Code: Reverse a Linked List', 22,
                  locked: true),
            ],
          ),
          Module(
            id: 'dsa-m3',
            title: 'Trees & Graphs',
            lessons: [
              _v('dsa-java-m3-l1', 'Binary Trees & Traversal', 19,
                  locked: true),
              _v('dsa-java-m3-l2', 'Graphs: BFS & DFS', 21, locked: true),
              _q('dsa-java-m3-l3', 'Final Quiz', 10, locked: true),
            ],
          ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Code projects
  // ---------------------------------------------------------------------------

  static List<CodeProject> get codeProjects => CodeSamples.projects;

  // ---------------------------------------------------------------------------
  // Forum
  // ---------------------------------------------------------------------------

  static List<ForumQuestion> get questions => [
        const ForumQuestion(
          id: 'q1',
          authorName: 'Arif Hossain',
          authorPhoto: 'assets/photos/person-male-cap.jpg',
          title: 'useEffect-এ infinite loop কেন হচ্ছে?',
          body:
              'আমার component-এ useEffect বারবার চলছে। dependency array-তে state দিয়েছি, কিন্তু তাও থামছে না। কী ভুল করছি?',
          tags: ['react', 'javascript'],
          upvotes: 24,
          answersCount: 3,
          createdLabel: '2h ago',
          accepted: true,
          answers: [
            ForumAnswer(
              id: 'q1-a1',
              authorName: 'Nusrat Jahan',
              authorPhoto: 'assets/photos/person-female-hijab.jpg',
              body:
                  'Dependency array-তে object বা function দিলে প্রতিবার নতুন reference তৈরি হয়, তাই effect বারবার চলে। Primitive value রাখুন, অথবা useCallback দিয়ে function memoize করুন।',
              upvotes: 31,
              accepted: true,
            ),
            ForumAnswer(
              id: 'q1-a2',
              authorName: 'Tanvir Hasan',
              authorPhoto: 'assets/photos/person-male-glasses.jpg',
              body:
                  'React DevTools-এ effect-টা inspect করুন — কোন dependency বদলাচ্ছে দেখতে পাবেন।',
              upvotes: 8,
            ),
            ForumAnswer(
              id: 'q1-a3',
              authorName: 'Rahim Uddin',
              authorPhoto: 'assets/photos/person-male-park.jpg',
              body:
                  'আমারও একই সমস্যা হয়েছিল — dependency থেকে object সরিয়ে দিতেই ঠিক হয়ে গেছে।',
              upvotes: 5,
            ),
          ],
        ),
        const ForumQuestion(
          id: 'q2',
          authorName: 'Maliha Akter',
          authorPhoto: 'assets/photos/person-female-curly.jpg',
          title: 'Python-এ list আর tuple-এর পার্থক্য কী?',
          body:
              'দুটোই তো sequence। কখন list ব্যবহার করব, কখন tuple? Performance-এ কোনো পার্থক্য আছে?',
          tags: ['python'],
          upvotes: 18,
          answersCount: 2,
          createdLabel: '5h ago',
          accepted: true,
          answers: [
            ForumAnswer(
              id: 'q2-a1',
              authorName: 'Tanvir Hasan',
              authorPhoto: 'assets/photos/person-male-glasses.jpg',
              body:
                  'List mutable — বদলানো যায়। Tuple immutable — একবার বানালে বদলানো যায় না। Fixed data (যেমন coordinates) tuple-এ রাখুন; tuple একটু দ্রুতও হয়।',
              upvotes: 22,
              accepted: true,
            ),
            ForumAnswer(
              id: 'q2-a2',
              authorName: 'Sakib Al Amin',
              authorPhoto: 'assets/photos/person-male-cap.jpg',
              body:
                  'আর tuple dict-এর key হতে পারে, list পারে না — কারণ key হতে হলে hashable হতে হয়।',
              upvotes: 11,
            ),
          ],
        ),
        const ForumQuestion(
          id: 'q3',
          authorName: 'Jannat Ferdous',
          authorPhoto: 'assets/photos/person-female-bd.jpg',
          title: 'Two Sum সমস্যাটা O(n)-এ কীভাবে করব?',
          body:
              'Brute force O(n²) দিয়ে করেছি, কিন্তু interview-এ O(n) চায়। HashMap দিয়ে approach-টা বুঝতে পারছি না।',
          tags: ['dsa', 'java'],
          upvotes: 32,
          answersCount: 3,
          createdLabel: '1d ago',
          accepted: false,
          answers: [
            ForumAnswer(
              id: 'q3-a1',
              authorName: 'Sakib Al Amin',
              authorPhoto: 'assets/photos/person-male-cap.jpg',
              body:
                  'প্রতিটা number-এর জন্য target - num খুঁজুন map-এ। পেলে indices return করুন, না পেলে num-টা map-এ রাখুন। একবার traverse করলেই হবে — O(n) time, O(n) space।',
              upvotes: 27,
            ),
            ForumAnswer(
              id: 'q3-a2',
              authorName: 'Arif Hossain',
              authorPhoto: 'assets/photos/person-male-cap.jpg',
              body:
                  'CodeShikhi-র Code tab-এ Two Sum প্রজেক্টটা দেখুন — ওখানে এই solution-টাই আছে।',
              upvotes: 9,
            ),
            ForumAnswer(
              id: 'q3-a3',
              authorName: 'Rahim Uddin',
              authorPhoto: 'assets/photos/person-male-park.jpg',
              body: 'ধন্যবাদ! HashMap approach-টা এখন পরিষ্কার।',
              upvotes: 3,
            ),
          ],
        ),
        const ForumQuestion(
          id: 'q4',
          authorName: 'Rifat Karim',
          authorPhoto: 'assets/photos/person-male-park.jpg',
          title: 'Flutter vs React Native — কোনটা শিখব?',
          body:
              'আমি mobile app বানাতে চাই। Flutter আর React Native-এর মধ্যে কোনটা শিখলে চাকরির বাজারে ভালো হবে?',
          tags: ['flutter', 'javascript'],
          upvotes: 41,
          answersCount: 2,
          createdLabel: '1d ago',
          accepted: false,
          answers: [
            ForumAnswer(
              id: 'q4-a1',
              authorName: 'Maliha Akter',
              authorPhoto: 'assets/photos/person-female-curly.jpg',
              body:
                  'দুটোই ভালো। JavaScript জানলে React Native দ্রুত শেখা যায়; Flutter-এর UI consistency আর performance একটু ভালো। বাংলাদেশে দুটোরই চাহিদা আছে।',
              upvotes: 19,
            ),
            ForumAnswer(
              id: 'q4-a2',
              authorName: 'Nusrat Jahan',
              authorPhoto: 'assets/photos/person-female-hijab.jpg',
              body:
                  'একটা ভালো করে শিখুন — framework-এর চেয়ে fundamentals বেশি গুরুত্বপূর্ণ।',
              upvotes: 14,
            ),
          ],
        ),
        const ForumQuestion(
          id: 'q5',
          authorName: 'Sadman Sakib',
          authorPhoto: 'assets/photos/person-male-glasses.jpg',
          title: 'JavaScript-এ closure আসলে কী?',
          body:
              'Closure নিয়ে অনেক tutorial দেখেছি, কিন্তু এখনো পুরো clear না। সহজ উদাহরণ দিয়ে কেউ বোঝাতে পারবেন?',
          tags: ['javascript'],
          upvotes: 15,
          answersCount: 2,
          createdLabel: '2d ago',
          accepted: true,
          answers: [
            ForumAnswer(
              id: 'q5-a1',
              authorName: 'Nusrat Jahan',
              authorPhoto: 'assets/photos/person-female-hijab.jpg',
              body:
                  'Closure হলো function + তার আশেপাশের variables-এর bundle। Inner function outer function-এর variables মনে রাখে, এমনকি outer function return করার পরেও।',
              upvotes: 20,
              accepted: true,
            ),
            ForumAnswer(
              id: 'q5-a2',
              authorName: 'Tanvir Hasan',
              authorPhoto: 'assets/photos/person-male-glasses.jpg',
              body:
                  'Counter example: function counter() { let c = 0; return () => ++c; } — returned function-টা c-কে মনে রাখে।',
              upvotes: 12,
            ),
          ],
        ),
        const ForumQuestion(
          id: 'q6',
          authorName: 'Farhana Islam',
          authorPhoto: 'assets/photos/person-female-mural.jpg',
          title: 'Recursion বুঝতে পারছি না — সাহায্য চাই',
          body:
              'Factorial-এর code দেখেছি, কিন্তু base case আর recursive call কীভাবে কাজ করে মাথায় ঢুকছে না।',
          tags: ['dsa', 'python'],
          upvotes: 12,
          answersCount: 2,
          createdLabel: '3d ago',
          accepted: false,
          answers: [
            ForumAnswer(
              id: 'q6-a1',
              authorName: 'Sakib Al Amin',
              authorPhoto: 'assets/photos/person-male-cap.jpg',
              body:
                  'Recursion মানে function নিজেকে ছোট সমস্যা দিয়ে ডাকে। Base case হলো থামার শর্ত — এটা না থাকলে infinite recursion হয়।',
              upvotes: 10,
            ),
            ForumAnswer(
              id: 'q6-a2',
              authorName: 'Rahim Uddin',
              authorPhoto: 'assets/photos/person-male-park.jpg',
              body:
                  'Call stack-টা কাগজে আঁকুন — factorial(3) → factorial(2) → factorial(1)। দেখলেই বুঝবেন।',
              upvotes: 7,
            ),
          ],
        ),
      ];

  // ---------------------------------------------------------------------------
  // Leaderboard (Rahim is rank 3 with 1,240 XP)
  // ---------------------------------------------------------------------------

  static const List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(
      name: 'Arif Hossain',
      photo: 'assets/photos/person-male-cap.jpg',
      xp: 1680,
      rank: 1,
    ),
    LeaderboardEntry(
      name: 'Nusrat Jahan',
      photo: 'assets/photos/person-female-hijab.jpg',
      xp: 1420,
      rank: 2,
    ),
    LeaderboardEntry(
      name: 'Rahim Uddin',
      photo: 'assets/photos/person-male-park.jpg',
      xp: 1240,
      rank: 3,
      isMe: true,
    ),
    LeaderboardEntry(
      name: 'Maliha Akter',
      photo: 'assets/photos/person-female-curly.jpg',
      xp: 1180,
      rank: 4,
    ),
    LeaderboardEntry(
      name: 'Tanvir Hasan',
      photo: 'assets/photos/person-male-glasses.jpg',
      xp: 990,
      rank: 5,
    ),
    LeaderboardEntry(
      name: 'Jannat Ferdous',
      photo: 'assets/photos/person-female-bd.jpg',
      xp: 860,
      rank: 6,
    ),
    LeaderboardEntry(
      name: 'Sakib Al Amin',
      photo: 'assets/photos/person-male-cap.jpg',
      xp: 740,
      rank: 7,
    ),
    LeaderboardEntry(
      name: 'Farhana Islam',
      photo: 'assets/photos/person-female-mural.jpg',
      xp: 620,
      rank: 8,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  static const List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'New lesson is live',
      body: '“useEffect & Data Fetching” is now available in React JS from Zero.',
      timeLabel: '10m ago',
      type: 'lesson',
    ),
    AppNotification(
      id: 'n2',
      title: 'Your streak is at risk!',
      body: 'You haven’t studied today. Complete one lesson to keep your 12-day streak.',
      timeLabel: '1h ago',
      type: 'streak',
    ),
    AppNotification(
      id: 'n3',
      title: 'Nusrat Jahan replied to you',
      body: '“Dependency array-তে object দিলে প্রতিবার নতুন reference তৈরি হয়…”',
      timeLabel: '3h ago',
      type: 'reply',
    ),
    AppNotification(
      id: 'n4',
      title: 'Certificate ready',
      body: 'Your Python in One Night certificate is ready to view and share.',
      timeLabel: '5h ago',
      type: 'certificate',
    ),
    AppNotification(
      id: 'n5',
      title: 'Payment successful',
      body: '৳1,500 paid for React JS from Zero via bKash. Invoice CS-2026-0142.',
      timeLabel: 'Yesterday',
      type: 'payment',
    ),
    AppNotification(
      id: 'n6',
      title: 'New course: Flutter from Zero',
      body: 'A brand-new Flutter course just landed. Check it out in the catalog.',
      timeLabel: 'Yesterday',
      type: 'course',
      read: true,
    ),
    AppNotification(
      id: 'n7',
      title: 'Study reminder',
      body: 'Your daily goal is 20 minutes. You’re 8 minutes away — keep going!',
      timeLabel: '2d ago',
      type: 'reminder',
      read: true,
    ),
    AppNotification(
      id: 'n8',
      title: 'Achievement unlocked',
      body: 'You earned the Rising Star badge for completing 10 lessons.',
      timeLabel: '3d ago',
      type: 'achievement',
      read: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Badges (all 12 Flaticon PNGs; first 5 unlocked)
  // ---------------------------------------------------------------------------

  static const List<BadgeInfo> badges = [
    BadgeInfo(
      id: 'medal_gold',
      name: 'Gold Medalist',
      description: 'Finish a course with a 90%+ quiz average.',
      assetPath: 'assets/badges/medal_gold.png',
      unlocked: true,
    ),
    BadgeInfo(
      id: 'medal_silver',
      name: 'Silver Medalist',
      description: 'Finish a course with an 80%+ quiz average.',
      assetPath: 'assets/badges/medal_silver.png',
      unlocked: true,
    ),
    BadgeInfo(
      id: 'medal_bronze',
      name: 'Bronze Medalist',
      description: 'Finish your first course.',
      assetPath: 'assets/badges/medal_bronze.png',
      unlocked: true,
    ),
    BadgeInfo(
      id: 'medal_wings',
      name: 'Fast Learner',
      description: 'Complete 5 lessons in a single day.',
      assetPath: 'assets/badges/medal_wings.png',
      unlocked: true,
    ),
    BadgeInfo(
      id: 'medal_star',
      name: 'Rising Star',
      description: 'Complete 10 lessons.',
      assetPath: 'assets/badges/medal_star.png',
      unlocked: true,
    ),
    BadgeInfo(
      id: 'rosette_first',
      name: 'First Place',
      description: 'Reach #1 on the weekly leaderboard.',
      assetPath: 'assets/badges/rosette_first.png',
    ),
    BadgeInfo(
      id: 'rosette_third',
      name: 'Top Three',
      description: 'Finish a week in the top 3.',
      assetPath: 'assets/badges/rosette_third.png',
    ),
    BadgeInfo(
      id: 'rosette_certificate',
      name: 'Certified',
      description: 'Earn 3 certificates.',
      assetPath: 'assets/badges/rosette_certificate.png',
    ),
    BadgeInfo(
      id: 'trophy_star',
      name: 'Star Performer',
      description: 'Score 100% on 5 quizzes.',
      assetPath: 'assets/badges/trophy_star.png',
    ),
    BadgeInfo(
      id: 'trophy_cup',
      name: 'Champion',
      description: 'Win a monthly challenge.',
      assetPath: 'assets/badges/trophy_cup.png',
    ),
    BadgeInfo(
      id: 'crown',
      name: 'Pro King',
      description: 'Become a Pro member.',
      assetPath: 'assets/badges/crown.png',
    ),
    BadgeInfo(
      id: 'coin_star',
      name: 'Volts Collector',
      description: 'Collect 1,000 Volts.',
      assetPath: 'assets/badges/coin_star.png',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  static const List<Order> orders = [
    Order(
      id: 'ord-1',
      courseTitle: 'React JS from Zero',
      amount: 1500,
      dateLabel: '12 Nov 2026',
      status: 'Paid',
      invoiceNo: 'CS-2026-0142',
      paymentMethod: 'bKash',
    ),
    Order(
      id: 'ord-2',
      courseTitle: 'Python in One Night',
      amount: 0,
      dateLabel: '08 Nov 2026',
      status: 'Free',
      invoiceNo: 'CS-2026-0131',
      paymentMethod: '—',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Coupons
  // ---------------------------------------------------------------------------

  static const List<Coupon> coupons = [
    Coupon(
      code: 'WELCOME10',
      description: 'Welcome offer for new learners',
      discountLabel: '-৳150',
      flatAmount: 150,
    ),
    Coupon(
      code: 'STUDENT20',
      description: 'Student discount with a valid student ID',
      discountLabel: '-20%',
      percent: 20,
    ),
  ];

  static Coupon? couponByCode(String code) {
    for (final c in coupons) {
      if (c.code.toUpperCase() == code.trim().toUpperCase()) return c;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Reviews (course detail)
  // ---------------------------------------------------------------------------

  static const List<Review> reviews = [
    Review(
      authorName: 'Arif Hossain',
      authorPhoto: 'assets/photos/person-male-cap.jpg',
      rating: 5,
      text:
          'বাংলায় এত সুন্দর করে React বোঝানো হয়েছে — একদম beginner-দের জন্য perfect।',
      timeLabel: '2d ago',
    ),
    Review(
      authorName: 'Jannat Ferdous',
      authorPhoto: 'assets/photos/person-female-bd.jpg',
      rating: 5,
      text: 'প্রতিটা lesson ছোট ছোট, বুঝতে সহজ। Quiz গুলো খুব helpful।',
      timeLabel: '1w ago',
    ),
    Review(
      authorName: 'Sadman Sakib',
      authorPhoto: 'assets/photos/person-male-glasses.jpg',
      rating: 4,
      text: 'ভালো course। আরো কিছু real project থাকলে আরো ভালো হতো।',
      timeLabel: '2w ago',
    ),
  ];
}
