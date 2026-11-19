import 'package:flutter/widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Every icon the app needs, in Linear (base name) and Bold (`_copy`)
/// weights. ALL constants below were verified against the installed
/// `iconsax_flutter` 1.0.1 package.
///
/// Verified name mappings (brief name -> package name) where they differ:
/// - trophy -> `cup` (no `trophy` in the package)
/// - target -> `flag` (no `target` in the package)
/// - plus -> `add` (no `plus` in the package)
/// - users -> `people` (no `users` in the package)
/// - globe -> `global` (no `globe` in the package)
/// - mic -> `microphone` (no `mic` in the package)
/// - shield -> `shield_tick` (`shield` has no Bold variant; `shield_tick`
///   has both weights)
class AppIcons {
  AppIcons._();

  // Tabs
  static const IconData tabHome = Iconsax.home_2;
  static const IconData tabHomeBold = Iconsax.home_2_copy;
  static const IconData tabCourses = Iconsax.book_1;
  static const IconData tabCoursesBold = Iconsax.book_1_copy;
  static const IconData tabCode = Iconsax.code_1;
  static const IconData tabCodeBold = Iconsax.code_1_copy;
  static const IconData tabCommunity = Iconsax.messages_1;
  static const IconData tabCommunityBold = Iconsax.messages_1_copy;
  static const IconData tabProfile = Iconsax.profile_circle;
  static const IconData tabProfileBold = Iconsax.profile_circle_copy;

  // Core navigation / actions
  static const IconData home = Iconsax.home_2;
  static const IconData homeBold = Iconsax.home_2_copy;
  static const IconData book = Iconsax.book_1;
  static const IconData bookBold = Iconsax.book_1_copy;
  static const IconData bookSaved = Iconsax.book_saved;
  static const IconData bookSavedBold = Iconsax.book_saved_copy;
  static const IconData code = Iconsax.code_1;
  static const IconData codeBold = Iconsax.code_1_copy;
  static const IconData codeCircle = Iconsax.code_circle;
  static const IconData codeCircleBold = Iconsax.code_circle_copy;
  static const IconData messages = Iconsax.messages_1;
  static const IconData messagesBold = Iconsax.messages_1_copy;
  static const IconData message = Iconsax.message;
  static const IconData messageBold = Iconsax.message_copy;
  static const IconData messageText = Iconsax.message_text;
  static const IconData messageTextBold = Iconsax.message_text_copy;
  static const IconData profile = Iconsax.profile_circle;
  static const IconData profileBold = Iconsax.profile_circle_copy;
  static const IconData search = Iconsax.search_normal_1;
  static const IconData searchBold = Iconsax.search_normal_1_copy;
  static const IconData searchAlt = Iconsax.search_normal;
  static const IconData searchAltBold = Iconsax.search_normal_copy;
  static const IconData bell = Iconsax.notification;
  static const IconData bellBold = Iconsax.notification_copy;
  static const IconData bellRing = Iconsax.notification_bing;
  static const IconData bellRingBold = Iconsax.notification_bing_copy;
  static const IconData settings = Iconsax.setting_2;
  static const IconData settingsBold = Iconsax.setting_2_copy;
  static const IconData filter = Iconsax.filter;
  static const IconData filterBold = Iconsax.filter_copy;
  static const IconData sliders = Iconsax.slider_horizontal;
  static const IconData slidersBold = Iconsax.slider_horizontal_copy;
  static const IconData sort = Iconsax.sort;
  static const IconData sortBold = Iconsax.sort_copy;
  static const IconData grid = Iconsax.grid_1;
  static const IconData gridBold = Iconsax.grid_1_copy;
  static const IconData category = Iconsax.category;
  static const IconData categoryBold = Iconsax.category_copy;

  // Arrows / chevrons
  static const IconData arrowLeft = Iconsax.arrow_left;
  static const IconData arrowLeftBold = Iconsax.arrow_left_copy;
  static const IconData arrowRight = Iconsax.arrow_right;
  static const IconData arrowRightBold = Iconsax.arrow_right_copy;
  static const IconData arrowUp = Iconsax.arrow_up_1;
  static const IconData arrowUpBold = Iconsax.arrow_up_1_copy;
  static const IconData arrowDown = Iconsax.arrow_down_1;
  static const IconData arrowDownBold = Iconsax.arrow_down_1_copy;
  static const IconData chevronLeft = Iconsax.arrow_left_2;
  static const IconData chevronLeftBold = Iconsax.arrow_left_2_copy;
  static const IconData chevronRight = Iconsax.arrow_right_2;
  static const IconData chevronRightBold = Iconsax.arrow_right_2_copy;
  static const IconData chevronUp = Iconsax.arrow_up_2;
  static const IconData chevronUpBold = Iconsax.arrow_up_2_copy;
  static const IconData chevronDown = Iconsax.arrow_down;
  static const IconData chevronDownBold = Iconsax.arrow_down_copy;
  static const IconData backCircle = Iconsax.arrow_circle_left;
  static const IconData backCircleBold = Iconsax.arrow_circle_left_copy;
  static const IconData refresh = Iconsax.refresh;
  static const IconData refreshBold = Iconsax.refresh_copy;

  // Media / player
  static const IconData play = Iconsax.play;
  static const IconData playBold = Iconsax.play_copy;
  static const IconData playCircle = Iconsax.play_circle;
  static const IconData playCircleBold = Iconsax.play_circle_copy;
  static const IconData pause = Iconsax.pause;
  static const IconData pauseBold = Iconsax.pause_copy;
  static const IconData stopCircle = Iconsax.stop_circle;
  static const IconData stopCircleBold = Iconsax.stop_circle_copy;
  static const IconData repeat = Iconsax.repeat;
  static const IconData repeatBold = Iconsax.repeat_copy;
  static const IconData video = Iconsax.video_play;
  static const IconData videoBold = Iconsax.video_play_copy;
  static const IconData videoCircle = Iconsax.video_circle;
  static const IconData videoCircleBold = Iconsax.video_circle_copy;
  static const IconData volume = Iconsax.volume_high;
  static const IconData volumeBold = Iconsax.volume_high_copy;
  static const IconData fullscreen = Iconsax.maximize_1;
  static const IconData fullscreenBold = Iconsax.maximize_1_copy;
  static const IconData fullscreenAlt = Iconsax.maximize_4;
  static const IconData fullscreenAltBold = Iconsax.maximize_4_copy;
  static const IconData mic = Iconsax.microphone;
  static const IconData micBold = Iconsax.microphone_copy;
  static const IconData micAlt = Iconsax.microphone_2;
  static const IconData micAltBold = Iconsax.microphone_2_copy;
  static const IconData camera = Iconsax.camera;
  static const IconData cameraBold = Iconsax.camera_copy;

  // Content / social
  static const IconData bookmark = Iconsax.bookmark;
  static const IconData bookmarkBold = Iconsax.bookmark_copy;
  static const IconData bookmarkAlt = Iconsax.bookmark_2;
  static const IconData bookmarkAltBold = Iconsax.bookmark_2_copy;
  static const IconData heart = Iconsax.heart;
  static const IconData heartBold = Iconsax.heart_copy;
  static const IconData heartSlash = Iconsax.heart_slash;
  static const IconData heartSlashBold = Iconsax.heart_slash_copy;
  static const IconData like = Iconsax.like_1;
  static const IconData likeBold = Iconsax.like_1_copy;
  static const IconData share = Iconsax.share;
  static const IconData shareBold = Iconsax.share_copy;
  static const IconData send = Iconsax.send;
  static const IconData sendBold = Iconsax.send_copy;
  static const IconData sendAlt = Iconsax.send_2;
  static const IconData sendAltBold = Iconsax.send_2_copy;
  static const IconData copy = Iconsax.copy;
  static const IconData copyBold = Iconsax.copy_copy;
  static const IconData link = Iconsax.link_1;
  static const IconData linkBold = Iconsax.link_1_copy;
  static const IconData eye = Iconsax.eye;
  static const IconData eyeBold = Iconsax.eye_copy;
  static const IconData eyeSlash = Iconsax.eye_slash;
  static const IconData eyeSlashBold = Iconsax.eye_slash_copy;
  static const IconData users = Iconsax.people;
  static const IconData usersBold = Iconsax.people_copy;
  static const IconData user = Iconsax.user;
  static const IconData userBold = Iconsax.user_copy;
  static const IconData profile2User = Iconsax.profile_2user;
  static const IconData profile2UserBold = Iconsax.profile_2user_copy;
  static const IconData teacher = Iconsax.teacher;
  static const IconData teacherBold = Iconsax.teacher_copy;

  // Status / feedback
  static const IconData check = Iconsax.tick_circle;
  static const IconData checkBold = Iconsax.tick_circle_copy;
  static const IconData checkSquare = Iconsax.tick_square;
  static const IconData checkSquareBold = Iconsax.tick_square_copy;
  static const IconData close = Iconsax.close_circle;
  static const IconData closeBold = Iconsax.close_circle_copy;
  static const IconData info = Iconsax.info_circle;
  static const IconData infoBold = Iconsax.info_circle_copy;
  static const IconData warning = Iconsax.warning_2;
  static const IconData warningBold = Iconsax.warning_2_copy;
  static const IconData danger = Iconsax.danger;
  static const IconData dangerBold = Iconsax.danger_copy;
  static const IconData star = Iconsax.star_1;
  static const IconData starBold = Iconsax.star_1_copy;
  static const IconData starAlt = Iconsax.star;
  static const IconData starAltBold = Iconsax.star_copy;

  // Gamification
  static const IconData crown = Iconsax.crown;
  static const IconData crownBold = Iconsax.crown_copy;
  static const IconData flash = Iconsax.flash_1;
  static const IconData flashBold = Iconsax.flash_1_copy;
  static const IconData trophy = Iconsax.cup;
  static const IconData trophyBold = Iconsax.cup_copy;
  static const IconData medal = Iconsax.medal;
  static const IconData medalBold = Iconsax.medal_copy;
  static const IconData medalStar = Iconsax.medal_star;
  static const IconData medalStarBold = Iconsax.medal_star_copy;
  static const IconData award = Iconsax.award;
  static const IconData awardBold = Iconsax.award_copy;
  static const IconData target = Iconsax.flag;
  static const IconData targetBold = Iconsax.flag_copy;
  static const IconData gift = Iconsax.gift;
  static const IconData giftBold = Iconsax.gift_copy;
  static const IconData chart = Iconsax.chart_1;
  static const IconData chartBold = Iconsax.chart_1_copy;
  static const IconData activity = Iconsax.activity;
  static const IconData activityBold = Iconsax.activity_copy;

  // Files / documents
  static const IconData download = Iconsax.import_1;
  static const IconData downloadBold = Iconsax.import_1_copy;
  static const IconData upload = Iconsax.export_1;
  static const IconData uploadBold = Iconsax.export_1_copy;
  static const IconData document = Iconsax.document;
  static const IconData documentBold = Iconsax.document_copy;
  static const IconData documentText = Iconsax.document_text;
  static const IconData documentTextBold = Iconsax.document_text_copy;
  static const IconData folder = Iconsax.folder;
  static const IconData folderBold = Iconsax.folder_copy;
  static const IconData folderOpen = Iconsax.folder_open;
  static const IconData folderOpenBold = Iconsax.folder_open_copy;
  static const IconData note = Iconsax.note_1;
  static const IconData noteBold = Iconsax.note_1_copy;
  static const IconData archive = Iconsax.archive;
  static const IconData archiveBold = Iconsax.archive_copy;
  static const IconData trash = Iconsax.trash;
  static const IconData trashBold = Iconsax.trash_copy;
  static const IconData edit = Iconsax.edit;
  static const IconData editBold = Iconsax.edit_copy;
  static const IconData brush = Iconsax.brush;
  static const IconData brushBold = Iconsax.brush_copy;
  static const IconData lamp = Iconsax.lamp;
  static const IconData lampBold = Iconsax.lamp_copy;
  static const IconData routing = Iconsax.routing;
  static const IconData routingBold = Iconsax.routing_copy;

  // Commerce / wallet
  static const IconData wallet = Iconsax.wallet;
  static const IconData walletBold = Iconsax.wallet_copy;
  static const IconData card = Iconsax.card;
  static const IconData cardBold = Iconsax.card_copy;
  static const IconData ticket = Iconsax.ticket;
  static const IconData ticketBold = Iconsax.ticket_copy;
  static const IconData money = Iconsax.moneys;
  static const IconData moneyBold = Iconsax.moneys_copy;
  static const IconData bank = Iconsax.bank;
  static const IconData bankBold = Iconsax.bank_copy;
  static const IconData receipt = Iconsax.receipt_1;
  static const IconData receiptBold = Iconsax.receipt_1_copy;
  static const IconData discount = Iconsax.discount_shape;
  static const IconData discountBold = Iconsax.discount_shape_copy;
  static const IconData briefcase = Iconsax.briefcase;
  static const IconData briefcaseBold = Iconsax.briefcase_copy;

  // System / misc
  static const IconData lock = Iconsax.lock;
  static const IconData lockBold = Iconsax.lock_copy;
  static const IconData unlock = Iconsax.unlock;
  static const IconData unlockBold = Iconsax.unlock_copy;
  static const IconData key = Iconsax.key;
  static const IconData keyBold = Iconsax.key_copy;
  static const IconData shield = Iconsax.shield_tick;
  static const IconData shieldBold = Iconsax.shield_tick_copy;
  static const IconData security = Iconsax.security_safe;
  static const IconData securityBold = Iconsax.security_safe_copy;
  static const IconData logout = Iconsax.logout;
  static const IconData logoutBold = Iconsax.logout_copy;
  static const IconData wifi = Iconsax.wifi;
  static const IconData wifiBold = Iconsax.wifi_copy;
  static const IconData globe = Iconsax.global;
  static const IconData globeBold = Iconsax.global_copy;
  static const IconData moon = Iconsax.moon;
  static const IconData moonBold = Iconsax.moon_copy;
  static const IconData sun = Iconsax.sun;
  static const IconData sunBold = Iconsax.sun_copy;
  static const IconData translate = Iconsax.translate;
  static const IconData translateBold = Iconsax.translate_copy;
  static const IconData clock = Iconsax.clock;
  static const IconData clockBold = Iconsax.clock_copy;
  static const IconData timer = Iconsax.timer_1;
  static const IconData timerBold = Iconsax.timer_1_copy;
  static const IconData calendar = Iconsax.calendar;
  static const IconData calendarBold = Iconsax.calendar_copy;
  static const IconData plus = Iconsax.add;
  static const IconData plusBold = Iconsax.add_copy;
  static const IconData plusCircle = Iconsax.add_circle;
  static const IconData plusCircleBold = Iconsax.add_circle_copy;
  static const IconData minus = Iconsax.minus;
  static const IconData minusBold = Iconsax.minus_copy;
  static const IconData more = Iconsax.more_2;
  static const IconData moreBold = Iconsax.more_2_copy;
}
