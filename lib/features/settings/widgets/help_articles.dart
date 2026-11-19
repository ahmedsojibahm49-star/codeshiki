/// Help Center articles (K15/K16). Real short help content — no lorem.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.title,
    required this.paragraphs,
  });

  final String id;
  final String title;
  final List<String> paragraphs;
}

const List<HelpArticle> helpArticles = [
  HelpArticle(
    id: 'getting-started',
    title: 'Getting started',
    paragraphs: [
      'Welcome to CodeShikhi! Start from the Home tab: pick a course that matches your goal — React JS from Zero is great if you want to build websites, Python in One Night if you are brand new to coding.',
      'Every course is made of short video lessons, readings and quizzes. Tap a lesson to watch it, and mark it complete when you finish. Your progress, XP and streak update automatically.',
      'Set a daily goal from your Profile so CodeShikhi can remind you to study a little every day. Even 20 minutes a day is enough to build a strong habit.',
      'Stuck on a lesson? Ask in the Community tab — other learners and mentors answer most questions within a few hours.',
    ],
  ),
  HelpArticle(
    id: 'downloads',
    title: 'How to download lessons',
    paragraphs: [
      'You can download video lessons to watch offline. Open any lesson and tap the Download button. The video is saved on your device and appears under My Courses > Downloads.',
      'Downloads need storage space on your phone. If a download fails, check that you have free space and a stable connection, then try again.',
      'To save mobile data, turn on Data Saver in Settings > Data Saver & downloads. You can also choose a lower video quality (480p) and restrict downloads to Wi-Fi only.',
      'Downloaded lessons stay on your device until you remove them. Open My Courses > Downloads > Manage storage to delete lessons you no longer need.',
    ],
  ),
  HelpArticle(
    id: 'payments',
    title: 'Payment methods (bKash / Nagad)',
    paragraphs: [
      'CodeShikhi accepts bKash, Nagad, Rocket and bank cards. When you buy a course or Pro, choose your payment method at checkout and follow the on-screen steps.',
      'For bKash, Nagad or Rocket you will send the amount to the CodeShikhi number shown at checkout, then enter the Transaction ID (TrxID) in the app. Our team verifies it — this usually takes a few minutes.',
      'After payment, your order appears in Profile > Orders with its invoice number. If a payment shows as Pending for more than an hour, contact support with your TrxID.',
      'Refunds: if you have watched less than 20% of a paid course and it has been less than 7 days since purchase, you can request a refund from Profile > Orders or by contacting support.',
    ],
  ),
  HelpArticle(
    id: 'certificates',
    title: 'Certificates',
    paragraphs: [
      'When you complete 100% of a course — all lessons and quizzes — your certificate is generated automatically. You will get a notification when it is ready.',
      'Find all your certificates in Profile > Certificates. From there you can view, download and share them.',
      'Certificates show your name as it appears in your account. If your name is spelled wrong, update it in Settings > Account before you finish a course.',
      'Employers and others can verify a certificate using the certificate ID printed on it. If a certificate is missing after completing a course, contact support.',
    ],
  ),
  HelpArticle(
    id: 'volts',
    title: 'Volts & rewards',
    paragraphs: [
      'Volts are CodeShikhi reward points. You earn them by completing lessons, keeping your streak alive, finishing quizzes with a high score and inviting friends.',
      'Spend Volts in the Rewards section of your Profile — for example on Pro discounts, extra quiz attempts and profile badges.',
      'Your daily streak grows by one each day you complete at least one lesson. Miss a day and the streak resets to zero, so turn on study reminders to protect it.',
      'Badges are earned automatically when you hit milestones, like finishing 10 lessons or a 7-day streak. View your collection in Profile > Badges.',
    ],
  ),
  HelpArticle(
    id: 'account',
    title: 'Account & privacy',
    paragraphs: [
      'Your name, bio and profile photo can be changed in Settings > Account. Your email address cannot be changed in the demo version of the app.',
      'Change your password in Settings > Change password. You will need your current password to set a new one.',
      'Control who can see your profile and XP in Settings > Privacy. You can limit your profile to friends and hide your XP from the leaderboard.',
      'To permanently delete your account and all your data, go to Settings > Delete account and follow the steps. This cannot be undone.',
    ],
  ),
];

HelpArticle? helpArticleById(String id) {
  for (final article in helpArticles) {
    if (article.id == id) return article;
  }
  return null;
}
