import 'package:flutter/material.dart';

IconData? mapEmojiIcon(String label) {
  const Map<String, IconData> emojiMap = {
    '🌟': Icons.auto_awesome_outlined,
    '⭐': Icons.star_outline,
    '🌍': Icons.public_outlined,
    '🎓': Icons.school_outlined,
    '👶': Icons.family_restroom_outlined,
    '💬': Icons.chat_bubble_outline,
    '💖': Icons.favorite_border,
    '❤': Icons.favorite_border,
    '🐾': Icons.pets_outlined,
    '🍺': Icons.local_bar_outlined,
    '🚬': Icons.smoking_rooms_outlined,
    '🍃': Icons.eco_outlined,
    '🏃': Icons.fitness_center_outlined,
    '🍽': Icons.restaurant_outlined,
    '☕': Icons.coffee_outlined,
    '📱': Icons.phone_android_outlined,
    '😴': Icons.bedtime_outlined,
    '🎵': Icons.music_note_outlined,
    '💪': Icons.fitness_center_outlined,
    '⚽': Icons.sports_soccer_outlined,
    '🎬': Icons.movie_outlined,
    '🎨': Icons.palette_outlined,
    '🎮': Icons.videogame_asset_outlined,
    '🌳': Icons.park_outlined,
    '🚶': Icons.directions_walk_outlined,
    '🎉': Icons.nightlife_outlined,
    '🛍': Icons.shopping_bag_outlined,
    '💼': Icons.work_outline,
    '📚': Icons.menu_book_outlined,
    '✈': Icons.flight_takeoff_outlined,
    '🎤': Icons.mic_none_outlined,
    '📸': Icons.photo_camera_outlined,
    '🏠': Icons.home_outlined,
    '🧘': Icons.self_improvement_outlined,
    '🎧': Icons.headphones_outlined,
    '🏋': Icons.fitness_center_outlined,
    '🚗': Icons.directions_car_outlined,
    '🏊': Icons.pool_outlined,
    '🚴': Icons.pedal_bike_outlined,
    '🏄': Icons.surfing_outlined,
    '⛰': Icons.terrain_outlined,
    '🏕': Icons.forest_outlined,
    '🎯': Icons.gps_fixed_outlined,
    '🎲': Icons.casino_outlined,
    '🧩': Icons.extension_outlined,
    '🎭': Icons.theater_comedy_outlined,
    '🎪': Icons.festival_outlined,
    '🍰': Icons.cake_outlined,
    '🍕': Icons.local_pizza_outlined,
    '🍜': Icons.ramen_dining_outlined,
    '🥗': Icons.restaurant_outlined,
    '🍷': Icons.wine_bar_outlined,
    '🥊': Icons.sports_mma_outlined,
    '🏸': Icons.sports_tennis_outlined,
    '⛳': Icons.sports_golf_outlined,
    '🧠': Icons.psychology_outlined,
    '💡': Icons.lightbulb_outlined,
    '💻': Icons.laptop_outlined,
    '🌱': Icons.spa_outlined,
    '🐶': Icons.pets_outlined,
    '🐱': Icons.pets_outlined,
    '✍': Icons.edit_note_outlined,
    '🛒': Icons.shopping_cart_outlined,
    '💄': Icons.face_retouching_natural_outlined,
    '📖': Icons.auto_stories_outlined,
    '🔮': Icons.auto_awesome_outlined,
    '💰': Icons.trending_up_outlined,
    '🤝': Icons.volunteer_activism_outlined,
    '🗣': Icons.record_voice_over_outlined,
    '🌐': Icons.translate_outlined,
  };

  final stripped = _stripVariationSelectors(label);

  for (final entry in emojiMap.entries) {
    if (stripped.contains(entry.key)) return entry.value;
  }

  return null;
}

String _stripVariationSelectors(String s) {
  return s.replaceAll('\uFE0F', '').replaceAll('\uFE0E', '');
}

IconData mapSelectionIcon(String label, {IconData fallback = Icons.label_outline}) {
  final emojiIcon = mapEmojiIcon(label);
  if (emojiIcon != null) return emojiIcon;

  final normalized = displaySelectionLabel(label).toLowerCase();

  // ─── Interest: ท่องเที่ยว ──────────────────────────
  if (_containsAny(normalized, ['ทะเล', 'เกาะ', 'ชายหาด', 'กิจกรรมชายหาด'])) return Icons.beach_access_outlined;
  if (_containsAny(normalized, ['ภูเขา', 'เดินป่า', 'ปีนเขา', 'ปีนหน้าผา', 'ธรรมชาติ', 'อุทยาน'])) return Icons.terrain_outlined;
  if (_containsAny(normalized, ['เมือง', 'ตลาด', 'สวนสาธารณะ', 'สำรวจเมือง', 'วัฒนธรรม'])) return Icons.location_city_outlined;
  if (_containsAny(normalized, ['ผจญภัย', 'เอ็กซ์ตรีม', 'โต้คลื่น', 'กระดาน', 'ดำน้ำ'])) return Icons.explore_outlined;
  if (_containsAny(normalized, ['เป้เดินทาง', 'backpacking', 'ต่างประเทศ', 'ในประเทศ'])) return Icons.flight_takeoff_outlined;
  if (_containsAny(normalized, ['หรูหรา'])) return Icons.diamond_outlined;
  if (_containsAny(normalized, ['ขับรถเที่ยว', 'รถแข่ง', 'ฟอร์มูล่า'])) return Icons.directions_car_outlined;
  if (_containsAny(normalized, ['สุดสัปดาห์'])) return Icons.weekend_outlined;
  if (_containsAny(normalized, ['แคมป์', 'ดูดาว', 'ปิกนิก'])) return Icons.forest_outlined;
  if (_containsAny(normalized, ['เที่ยวคนเดียว'])) return Icons.person_outline;
  if (_containsAny(normalized, ['เที่ยวกลุ่ม'])) return Icons.groups_outlined;

  // ─── Interest: ดนตรี ───────────────────────────────
  if (_containsAny(normalized, ['ร้องเพลง', 'คาราโอเกะ'])) return Icons.mic_none_outlined;
  if (_containsAny(normalized, ['เล่นดนตรี'])) return Icons.piano_outlined;
  if (_containsAny(normalized, ['ดนตรีสด'])) return Icons.speaker_outlined;
  if (_containsAny(normalized, ['เพลง', 'ดนตรี', 'คอนเสิร์ต', 'เทศกาลดนตรี', 'ป๊อป', 'ร็อค', 'อินดี้', 'ฮิปฮอป', 'แร็พ', 'อาร์แอนด์บี', 'โซล', 'edm', 'อิเล็กทรอนิกส์', 'แจ๊ส', 'บลูส์', 'คลาสสิก', 'ลูกทุ่ง', 'ลูกกรุง', 'เคป๊อป', 'เจป๊อป', 'ทีป๊อป'])) return Icons.music_note_outlined;

  // ─── Interest: ออกกำลังกาย ─────────────────────────
  if (_containsAny(normalized, ['โยคะ', 'พิลาทิส'])) return Icons.self_improvement_outlined;
  if (_containsAny(normalized, ['วิ่ง', 'จ็อกกิ้ง', 'นักวิ่ง'])) return Icons.directions_run_outlined;
  if (_containsAny(normalized, ['ยกน้ำหนัก', 'เพาะกาย', 'ฟิตเนส', 'คาร์ดิโอ', 'ออกกำลังกาย'])) return Icons.fitness_center_outlined;
  if (_containsAny(normalized, ['ปั่นจักรยาน'])) return Icons.pedal_bike_outlined;
  if (_containsAny(normalized, ['ว่ายน้ำ'])) return Icons.pool_outlined;
  if (_containsAny(normalized, ['มวย', 'ศิลปะการต่อสู้'])) return Icons.sports_mma_outlined;
  if (_containsAny(normalized, ['เต้น', 'ซุมบ้า', 'แอโรบิก'])) return Icons.music_video_outlined;

  // ─── Interest: กีฬา ────────────────────────────────
  if (_containsAny(normalized, ['ฟุตบอล'])) return Icons.sports_soccer_outlined;
  if (_containsAny(normalized, ['บาสเกตบอล'])) return Icons.sports_basketball_outlined;
  if (_containsAny(normalized, ['วอลเลย์'])) return Icons.sports_volleyball_outlined;
  if (_containsAny(normalized, ['แบดมินตัน'])) return Icons.sports_tennis_outlined;
  if (_containsAny(normalized, ['เทนนิส'])) return Icons.sports_tennis_outlined;
  if (_containsAny(normalized, ['กอล์ฟ'])) return Icons.sports_golf_outlined;
  if (_containsAny(normalized, ['เบสบอล'])) return Icons.sports_baseball_outlined;
  if (_containsAny(normalized, ['รักบี้'])) return Icons.sports_football_outlined;
  if (_containsAny(normalized, ['อีสปอร์ต'])) return Icons.videogame_asset_outlined;
  if (_containsAny(normalized, ['กีฬา', 'ดูกีฬา'])) return Icons.emoji_events_outlined;

  // ─── Interest: หนัง/ซีรีส์ ─────────────────────────
  if (_containsAny(normalized, ['สารคดี'])) return Icons.live_tv_outlined;
  if (_containsAny(normalized, ['โรงภาพยนตร์'])) return Icons.local_movies_outlined;
  if (_containsAny(normalized, ['หนัง', 'ซีรีส์', 'netflix', 'แอนิเมชั่น', 'การ์ตูน', 'แอ็คชั่น', 'ตลก', 'ดราม่า', 'สยองขวัญ', 'ระทึก', 'โรแมนติก', 'ไซไฟ', 'แฟนตาซี', 'คอหนัง', 'คอซีรีส์', 'ติ่งซีรีส์'])) return Icons.movie_outlined;

  // ─── Interest: ศิลปะ ───────────────────────────────
  if (_containsAny(normalized, ['วาด', 'ศิลปะ', 'หอศิลป์', 'พิพิธภัณฑ์', 'สตรีทอาร์ต', 'ศิลปะดิจิทัล'])) return Icons.palette_outlined;
  if (_containsAny(normalized, ['ถ่ายภาพ', 'ถ่ายรูป', 'ถ่ายคลิป'])) return Icons.photo_camera_outlined;
  if (_containsAny(normalized, ['ออกแบบ', 'ดีไซน์', 'กราฟิก', 'แฟชั่น', 'ตกแต่ง', 'สถาปัตยกรรม', 'ชอบแต่งตัว', 'สตรีทแวร์'])) return Icons.design_services_outlined;
  if (_containsAny(normalized, ['เขียนหนังสือ', 'บทกวี', 'หนอนหนังสือ'])) return Icons.edit_note_outlined;
  if (_containsAny(normalized, ['diy', 'งานฝีมือ', 'นักสะสม'])) return Icons.handyman_outlined;

  // ─── Interest: เกม/เทค ─────────────────────────────
  if (_containsAny(normalized, ['บอร์ดเกม', 'เกมไพ่'])) return Icons.casino_outlined;
  if (_containsAny(normalized, ['เกม', 'เกมเมอร์', 'คอเกม', 'rpg', 'fps', 'กลยุทธ์', 'คอนโซล', 'พีซี', 'มือถือ', 'vr', 'พัฒนาเกม'])) return Icons.videogame_asset_outlined;
  if (_containsAny(normalized, ['เขียนโปรแกรม', 'ai', 'นวัตกรรม'])) return Icons.terminal_outlined;
  if (_containsAny(normalized, ['เทคโนโลยี', 'แก็ดเจ็ต'])) return Icons.memory_outlined;

  // ─── Interest: อาหาร/เครื่องดื่ม ───────────────────
  if (_containsAny(normalized, ['กาแฟ', 'คาเฟ่', 'คอกาแฟ', 'สายคาเฟ่'])) return Icons.coffee_outlined;
  if (_containsAny(normalized, ['ชา', 'นมไข่มุก', 'คอชา'])) return Icons.local_cafe_outlined;
  if (_containsAny(normalized, ['ทำขนม', 'เบเกอรี่', 'ของหวาน', 'สายหวาน'])) return Icons.cake_outlined;
  if (_containsAny(normalized, ['ญี่ปุ่น', 'เกาหลี', 'อิตาเลียน', 'จีน', 'ไทย', 'ริมทาง', 'หรู', 'ทำอาหาร', 'กินเล่น', 'อาหาร', 'ร้านอาหาร', 'ขนม', 'ชาบู', 'ปิ้งย่าง', 'สายเนื้อ'])) return Icons.restaurant_outlined;

  // ─── Interest: กลางแจ้ง/ธรรมชาติ ───────────────────
  if (_containsAny(normalized, ['สวน', 'ปลูกต้นไม้', 'รักษ์โลก', 'สิ่งแวดล้อม', 'นักปลูก', 'รักธรรมชาติ'])) return Icons.spa_outlined;
  if (_containsAny(normalized, ['ปลา', 'ตกปลา', 'คายัค', 'พายเรือ'])) return Icons.phishing_outlined;
  if (_containsAny(normalized, ['ดูนก', 'สัตว์ป่า'])) return Icons.visibility_outlined;

  // ─── Interest: เดิน/ไลฟ์สไตล์ ─────────────────────
  if (_containsAny(normalized, ['เดินเล่น', 'เดินเช้า', 'เดินเย็น', 'เดินถ่าย', 'พาสุนัข'])) return Icons.directions_walk_outlined;

  // ─── Interest: ไนท์ไลฟ์ ────────────────────────────
  if (_containsAny(normalized, ['บาร์', 'ผับ', 'ค็อกเทล', 'รูฟท็อป', 'คลับ', 'ล่าบาร์', 'ตลาดกลางคืน', 'กินข้าวดึก', 'ฟังเพลงสด'])) return Icons.local_bar_outlined;

  // ─── Interest: ช้อปปิ้ง ────────────────────────────
  if (_containsAny(normalized, ['ช้อป', 'รองเท้า', 'สนีกเกอร์', 'เครื่องประดับ', 'วินเทจ', 'แบรนด์', 'ออนไลน์', 'ห้าง'])) return Icons.shopping_bag_outlined;
  if (_containsAny(normalized, ['ความงาม', 'ดูแลผิว'])) return Icons.face_retouching_natural_outlined;

  // ─── Interest: การงาน ──────────────────────────────
  if (_containsAny(normalized, ['ธุรกิจ', 'สตาร์ทอัพ', 'อาชีพ', 'รายได้เสริม', 'ผู้ประกอบการ', 'เครือข่าย'])) return Icons.work_outline;
  if (_containsAny(normalized, ['ลงทุน'])) return Icons.trending_up_outlined;
  if (_containsAny(normalized, ['พัฒนาตนเอง', 'ความเป็นผู้นำ', 'พูดในที่สาธารณะ', 'พัฒนาอาชีพ'])) return Icons.psychology_outlined;

  // ─── Interest: อาสาสมัคร ───────────────────────────
  if (_containsAny(normalized, ['การกุศล', 'ชุมชน', 'อาสา', 'บริการ'])) return Icons.volunteer_activism_outlined;

  // ─── Interest: ภาษา/การศึกษา ───────────────────────
  if (_containsAny(normalized, ['ภาษา', 'อังกฤษ', 'จีน', 'ญี่ปุ่น', 'เกาหลี', 'แลกเปลี่ยนภาษา', 'เรียนภาษา'])) return Icons.translate_outlined;

  // ─── Lifestyle: ราศี ───────────────────────────────
  if (_containsAny(normalized, ['ราศี', 'สายมู', 'มูเตลู', 'ดูดวง'])) return Icons.auto_awesome_outlined;

  // ─── Lifestyle: การศึกษา ───────────────────────────
  if (_containsAny(normalized, ['ปริญญา', 'มหาวิทยาลัย', 'วิทยาลัย', 'มัธยม', 'กำลังเรียน'])) return Icons.school_outlined;

  // ─── Lifestyle: ครอบครัว ───────────────────────────
  if (_containsAny(normalized, ['ลูก', 'ครอบครัว', 'รักครอบครัว'])) return Icons.family_restroom_outlined;
  if (_containsAny(normalized, ['ยังไม่แน่ใจ'])) return Icons.help_outline;

  // ─── Lifestyle: สื่อสาร ────────────────────────────
  if (_containsAny(normalized, ['แชท', 'โทรศัพท์', 'วิดีโอคอล', 'เจอหน้ากัน', 'ไม่ค่อยแชท'])) return Icons.chat_bubble_outline;

  // ─── Lifestyle: แสดงความรัก ────────────────────────
  if (_containsAny(normalized, ['ของขวัญ', 'คำชม', 'เอาใจใส่', 'สัมผัส', 'เวลาร่วมกัน', 'การกระทำ'])) return Icons.favorite_border;

  // ─── Lifestyle: สัตว์เลี้ยง ────────────────────────
  if (_containsAny(normalized, ['หมา', 'สุนัข', 'ทาสหมา'])) return Icons.pets_outlined;
  if (_containsAny(normalized, ['แมว', 'ทาสแมว'])) return Icons.pets_outlined;
  if (_containsAny(normalized, ['สัตว์', 'นก', 'ปลา', 'เต่า', 'หนูแฮมสเตอร์', 'กระต่าย', 'เลื้อยคลาน', 'ครึ่งบกครึ่งน้ำ', 'รักสัตว์', 'ภูมิแพ้สัตว์', 'อยากมีสัตว์เลี้ยง', 'ไม่เลี้ยง', 'ไม่มี แต่รัก', 'อื่นๆ', 'แพ้ขน'])) return Icons.pets_outlined;

  // ─── Lifestyle: ดื่ม/สูบ/กัญชา ────────────────────
  if (_containsAny(normalized, ['เหล้า', 'ดื่ม', 'สังสรรค์', 'แทบทุกคืน', 'เลือกที่จะไม่', 'ไม่ใช่ทาง'])) return Icons.local_bar_outlined;
  if (_containsAny(normalized, ['บุหรี่', 'สูบ', 'นักสูบ', 'พยายามเลิก'])) return Icons.smoking_rooms_outlined;
  if (_containsAny(normalized, ['กัญชา', 'เป็นครั้งคราว', 'ไม่เคย'])) return Icons.eco_outlined;

  // ─── Lifestyle: อาหารที่กินได้ ─────────────────────
  if (_containsAny(normalized, ['วีแกน', 'มังสวิรัติ', 'ฮาลาล', 'โคเชอร์', 'อาหารทะเล', 'เนื้อสัตว์', 'ผัก'])) return Icons.restaurant_outlined;

  // ─── Lifestyle: โซเชียล ────────────────────────────
  if (_containsAny(normalized, ['โซเชียล', 'tiktoker', 'คอนเทนต์', 'รีวิว', 'เน็ตไอดอล', 'ไถฟีด', 'ไม่เล่น', 'สายโซเชียล'])) return Icons.smart_display_outlined;

  // ─── Lifestyle: การนอน ─────────────────────────────
  if (_containsAny(normalized, ['ตื่นเช้า', 'นอนดึก', 'กลางๆ'])) return Icons.bedtime_outlined;

  // ─── Lifestyle: ออกกำลังกาย (frequency) ────────────
  if (_containsAny(normalized, ['ทุกวัน', 'ค่อนข้างบ่อย', 'เป็นบางครั้ง'])) return Icons.fitness_center_outlined;

  // ─── Tag: บุคลิก ───────────────────────────────────
  if (_containsAny(normalized, ['อินโทรเวิร์ต', 'เอ็กซ์โทรเวิร์ต', 'โลกส่วนตัวสูง'])) return Icons.person_outline;
  if (_containsAny(normalized, ['สายชิล'])) return Icons.weekend_outlined;
  if (_containsAny(normalized, ['สายลุย'])) return Icons.flash_on_outlined;
  if (_containsAny(normalized, ['สายฮา'])) return Icons.sentiment_very_satisfied_outlined;
  if (_containsAny(normalized, ['สายเปย์'])) return Icons.card_giftcard_outlined;
  if (_containsAny(normalized, ['สายหวาน'])) return Icons.favorite_border;
  if (_containsAny(normalized, ['สายติสท์'])) return Icons.palette_outlined;
  if (_containsAny(normalized, ['อยู่บ้าน'])) return Icons.home_outlined;
  if (_containsAny(normalized, ['ออกนอกบ้าน'])) return Icons.explore_outlined;
  if (_containsAny(normalized, ['อบอุ่น', 'จริงจัง', 'สายบวก', 'เปิดใจ', 'พูดตรง', 'ไม่ชอบดราม่า'])) return Icons.favorite_outline;
  if (_containsAny(normalized, ['สายเกา'])) return Icons.star_outline;
  if (_containsAny(normalized, ['สายฝอ'])) return Icons.star_outline;

  // ─── Tag: ไลฟ์สไตล์ ────────────────────────────────
  if (_containsAny(normalized, ['สายแคมป์'])) return Icons.forest_outlined;
  if (_containsAny(normalized, ['รักทะเล'])) return Icons.beach_access_outlined;
  if (_containsAny(normalized, ['ชอบเที่ยว'])) return Icons.flight_takeoff_outlined;
  if (_containsAny(normalized, ['ชอบฟังเพลง'])) return Icons.headphones_outlined;
  if (_containsAny(normalized, ['ชอบเต้น'])) return Icons.music_video_outlined;

  // ─── Tag: ความคิด/ค่านิยม ─────────────────────────
  if (_containsAny(normalized, ['สายธรรมะ'])) return Icons.temple_buddhist_outlined;
  if (_containsAny(normalized, ['รักอิสระ'])) return Icons.air_outlined;
  if (_containsAny(normalized, ['รักเดียวใจเดียว'])) return Icons.favorite_outlined;
  if (_containsAny(normalized, ['สายฮีล'])) return Icons.healing_outlined;

  // ─── Tag: MBTI ─────────────────────────────────────
  if (_containsAny(normalized, ['intj', 'intp', 'entj', 'entp', 'infj', 'infp', 'enfj', 'enfp', 'istj', 'isfj', 'estj', 'esfj', 'istp', 'isfp', 'estp', 'esfp'])) return Icons.psychology_outlined;

  return fallback;
}

bool _containsAny(String value, List<String> patterns) {
  return patterns.any(value.contains);
}

String displaySelectionLabel(String label) {
  return label.replaceAll(
    RegExp(
      r'[\u{200D}\u{FE0E}\u{FE0F}\u{20E3}'
      r'\u{2000}-\u{27BF}'
      r'\u{2B05}-\u{2BFF}'
      r'\u{3000}-\u{303F}'
      r'\u{3297}\u{3299}'
      r'\u{E000}-\u{F8FF}'
      r'\u{FE00}-\u{FE0F}'
      r'\u{1F000}-\u{1FFFF}'
      r'\u{E0020}-\u{E007F}]',
      unicode: true,
    ),
    '',
  ).trim();
}
