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
    '❤️': Icons.favorite_border,
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
  };

  for (final entry in emojiMap.entries) {
    if (label.contains(entry.key)) return entry.value;
  }

  return null;
}

IconData mapSelectionIcon(String label, {IconData fallback = Icons.label_outline}) {
  final emojiIcon = mapEmojiIcon(label);
  if (emojiIcon != null) return emojiIcon;

  final normalized = displaySelectionLabel(label).toLowerCase();

  if (_containsAny(normalized, ['ทะเล', 'เกาะ', 'ชายหาด'])) {
    return Icons.beach_access_outlined;
  }
  if (_containsAny(normalized, ['ภูเขา', 'เดินป่า', 'ปีนเขา', 'ธรรมชาติ', 'อุทยาน'])) {
    return Icons.terrain_outlined;
  }
  if (_containsAny(normalized, ['เมือง', 'ตลาด', 'สวนสาธารณะ', 'สำรวจเมือง'])) {
    return Icons.location_city_outlined;
  }
  if (_containsAny(normalized, ['อาหาร', 'ร้านอาหาร', 'ขนม', 'ชาบู', 'ปิ้งย่าง'])) {
    return Icons.restaurant_outlined;
  }
  if (_containsAny(normalized, ['กาแฟ', 'คาเฟ่'])) {
    return Icons.coffee_outlined;
  }
  if (_containsAny(normalized, ['ชา', 'นมไข่มุก'])) {
    return Icons.local_cafe_outlined;
  }
  if (_containsAny(normalized, ['ผจญภัย', 'เอ็กซ์ตรีม', 'โต้คลื่น', 'ดำน้ำ'])) {
    return Icons.explore_outlined;
  }
  if (_containsAny(normalized, ['ขับรถ', 'รถแข่ง', 'ฟอร์มูล่า'])) {
    return Icons.directions_car_outlined;
  }
  if (_containsAny(normalized, ['ต่างประเทศ', 'เดินทาง', 'backpacking'])) {
    return Icons.flight_takeoff_outlined;
  }
  if (_containsAny(normalized, ['แคมป์', 'ดูดาว', 'ปิกนิก'])) {
    return Icons.forest_outlined;
  }
  if (_containsAny(normalized, ['เพลง', 'ดนตรี', 'คอนเสิร์ต', 'เทศกาลดนตรี'])) {
    return Icons.music_note_outlined;
  }
  if (_containsAny(normalized, ['ร้องเพลง', 'คาราโอเกะ'])) {
    return Icons.mic_none_outlined;
  }
  if (_containsAny(normalized, ['เล่นดนตรี'])) {
    return Icons.piano_outlined;
  }
  if (_containsAny(normalized, ['โยคะ', 'พิลาทิส'])) {
    return Icons.self_improvement_outlined;
  }
  if (_containsAny(normalized, ['วิ่ง', 'จ็อกกิ้ง'])) {
    return Icons.directions_run_outlined;
  }
  if (_containsAny(normalized, ['ยกน้ำหนัก', 'เพาะกาย', 'ฟิตเนส', 'คาร์ดิโอ', 'ออกกำลังกาย'])) {
    return Icons.fitness_center_outlined;
  }
  if (_containsAny(normalized, ['ปั่นจักรยาน'])) {
    return Icons.pedal_bike_outlined;
  }
  if (_containsAny(normalized, ['ว่ายน้ำ'])) {
    return Icons.pool_outlined;
  }
  if (_containsAny(normalized, ['มวย', 'ศิลปะการต่อสู้'])) {
    return Icons.sports_mma_outlined;
  }
  if (_containsAny(normalized, ['เต้น', 'ซุมบ้า', 'แอโรบิก'])) {
    return Icons.music_video_outlined;
  }
  if (_containsAny(normalized, ['ฟุตบอล'])) {
    return Icons.sports_soccer_outlined;
  }
  if (_containsAny(normalized, ['บาส'])) {
    return Icons.sports_basketball_outlined;
  }
  if (_containsAny(normalized, ['วอลเลย์'])) {
    return Icons.sports_volleyball_outlined;
  }
  if (_containsAny(normalized, ['แบด'])) {
    return Icons.sports_tennis_outlined;
  }
  if (_containsAny(normalized, ['เทนนิส'])) {
    return Icons.sports_tennis_outlined;
  }
  if (_containsAny(normalized, ['กอล์ฟ'])) {
    return Icons.sports_golf_outlined;
  }
  if (_containsAny(normalized, ['เบสบอล'])) {
    return Icons.sports_baseball_outlined;
  }
  if (_containsAny(normalized, ['รักบี้'])) {
    return Icons.sports_football_outlined;
  }
  if (_containsAny(normalized, ['กีฬา', 'ดูกีฬา'])) {
    return Icons.emoji_events_outlined;
  }
  if (_containsAny(normalized, ['หนัง', 'ซีรีส์', 'netflix', 'แอนิเมะ', 'แอนิเมชั่น'])) {
    return Icons.movie_outlined;
  }
  if (_containsAny(normalized, ['สารคดี'])) {
    return Icons.live_tv_outlined;
  }
  if (_containsAny(normalized, ['วาด', 'ศิลปะ', 'หอศิลป์', 'พิพิธภัณฑ์', 'สตรีทอาร์ต'])) {
    return Icons.palette_outlined;
  }
  if (_containsAny(normalized, ['ถ่ายภาพ', 'ถ่ายรูป', 'ถ่ายคลิป'])) {
    return Icons.photo_camera_outlined;
  }
  if (_containsAny(normalized, ['ออกแบบ', 'ดีไซน์', 'แฟชั่น', 'ตกแต่ง', 'สถาปัตยกรรม'])) {
    return Icons.design_services_outlined;
  }
  if (_containsAny(normalized, ['เขียนหนังสือ', 'บทกวี', 'หนอนหนังสือ'])) {
    return Icons.edit_note_outlined;
  }
  if (_containsAny(normalized, ['diy', 'งานฝีมือ', 'นักสะสม'])) {
    return Icons.handyman_outlined;
  }
  if (_containsAny(normalized, ['เกม', 'เกมเมอร์', 'esport', 'อีสปอร์ต'])) {
    return Icons.videogame_asset_outlined;
  }
  if (_containsAny(normalized, ['บอร์ดเกม', 'เกมไพ่'])) {
    return Icons.casino_outlined;
  }
  if (_containsAny(normalized, ['เทคโนโลยี', 'แก็ดเจ็ต'])) {
    return Icons.memory_outlined;
  }
  if (_containsAny(normalized, ['เขียนโปรแกรม', 'ai', 'นวัตกรรม'])) {
    return Icons.terminal_outlined;
  }
  if (_containsAny(normalized, ['สวน', 'ปลูกต้นไม้', 'รักษ์โลก', 'สิ่งแวดล้อม'])) {
    return Icons.spa_outlined;
  }
  if (_containsAny(normalized, ['ปลา', 'ตกปลา', 'คายัค'])) {
    return Icons.phishing_outlined;
  }
  if (_containsAny(normalized, ['หมา', 'สุนัข'])) {
    return Icons.pets_outlined;
  }
  if (_containsAny(normalized, ['แมว'])) {
    return Icons.pets_outlined;
  }
  if (_containsAny(normalized, ['สัตว์', 'นก', 'สัตว์ป่า'])) {
    return Icons.pets_outlined;
  }
  if (_containsAny(normalized, ['บาร์', 'ผับ', 'ค็อกเทล', 'รูฟท็อป', 'คลับ'])) {
    return Icons.local_bar_outlined;
  }
  if (_containsAny(normalized, ['ช้อป', 'รองเท้า', 'เครื่องประดับ', 'วินเทจ', 'แบรนด์'])) {
    return Icons.shopping_bag_outlined;
  }
  if (_containsAny(normalized, ['ความงาม', 'ดูแลผิว'])) {
    return Icons.face_retouching_natural_outlined;
  }
  if (_containsAny(normalized, ['ธุรกิจ', 'สตาร์ทอัพ', 'อาชีพ', 'รายได้เสริม'])) {
    return Icons.work_outline;
  }
  if (_containsAny(normalized, ['ลงทุน'])) {
    return Icons.trending_up_outlined;
  }
  if (_containsAny(normalized, ['พัฒนาตนเอง', 'ความเป็นผู้นำ', 'พูดในที่สาธารณะ'])) {
    return Icons.psychology_outlined;
  }
  if (_containsAny(normalized, ['การกุศล', 'ชุมชน', 'อาสา'])) {
    return Icons.volunteer_activism_outlined;
  }
  if (_containsAny(normalized, ['ภาษา', 'อังกฤษ', 'จีน', 'ญี่ปุ่น', 'เกาหลี', 'แลกเปลี่ยนภาษา'])) {
    return Icons.translate_outlined;
  }
  if (_containsAny(normalized, ['ราศี'])) {
    return Icons.auto_awesome_outlined;
  }
  if (_containsAny(normalized, ['ปริญญา', 'มหาวิทยาลัย', 'วิทยาลัย', 'มัธยม'])) {
    return Icons.school_outlined;
  }
  if (_containsAny(normalized, ['ลูก', 'ครอบครัว'])) {
    return Icons.family_restroom_outlined;
  }
  if (_containsAny(normalized, ['แชท', 'โทรศัพท์', 'วิดีโอคอล', 'เจอหน้ากัน'])) {
    return Icons.chat_bubble_outline;
  }
  if (_containsAny(normalized, ['ของขวัญ', 'คำชม', 'เอาใจใส่', 'สัมผัส', 'เวลาร่วมกัน'])) {
    return Icons.favorite_border;
  }
  if (_containsAny(normalized, ['เหล้า', 'ดื่ม'])) {
    return Icons.local_bar_outlined;
  }
  if (_containsAny(normalized, ['บุหรี่', 'สูบ'])) {
    return Icons.smoking_rooms_outlined;
  }
  if (_containsAny(normalized, ['กัญชา'])) {
    return Icons.eco_outlined;
  }
  if (_containsAny(normalized, ['วีแกน', 'มังสวิรัติ', 'ฮาลาล', 'โคเชอร์', 'อาหารทะเล'])) {
    return Icons.restaurant_outlined;
  }
  if (_containsAny(normalized, ['โซเชียล', 'tiktoker', 'คอนเทนต์', 'รีวิว'])) {
    return Icons.smart_display_outlined;
  }
  if (_containsAny(normalized, ['ตื่นเช้า', 'นอนดึก'])) {
    return Icons.bedtime_outlined;
  }
  if (_containsAny(normalized, ['อินโทรเวิร์ต', 'เอ็กซ์โทรเวิร์ต', 'โลกส่วนตัวสูง'])) {
    return Icons.person_outline;
  }
  if (_containsAny(normalized, ['สายมู', 'มูเตลู', 'ดูดวง'])) {
    return Icons.auto_awesome_outlined;
  }
  if (_containsAny(normalized, ['อบอุ่น', 'จริงจัง', 'สายบวก', 'เปิดใจ', 'พูดตรง', 'ไม่ชอบดราม่า'])) {
    return Icons.favorite_outline;
  }
  if (_containsAny(normalized, ['mbti', 'intj', 'intp', 'entj', 'entp', 'infj', 'infp', 'enfj', 'enfp', 'istj', 'isfj', 'estj', 'esfj', 'istp', 'isfp', 'estp', 'esfp'])) {
    return Icons.psychology_outlined;
  }

  return fallback;
}

bool _containsAny(String value, List<String> patterns) {
  return patterns.any(value.contains);
}

String displaySelectionLabel(String label) {
  return label.replaceAll(
    RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true),
    '',
  ).trim();
}
