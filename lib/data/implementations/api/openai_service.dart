import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  final String apiKey;

  OpenAiService({required this.apiKey});

  /// Gọi OpenAI ChatCompletion API để gợi ý mẫu lời chúc Tết
  /// [title] — tiêu đề mẫu (có thể rỗng)
  /// [groups] — danh sách nhóm đối tượng (VD: ['Gia đình', 'Sếp'])
  Future<String> generateWishTemplate({
    required String title,
    required List<String> groups,
  }) async {
    final groupText = groups.isNotEmpty ? groups.join(', ') : 'chung';

    final prompt = '''
Bạn là chuyên gia viết lời chúc Tết Nguyên Đán bằng tiếng Việt.
Hãy tạo một lời chúc Tết hay, chân thành và phù hợp với nhóm đối tượng: $groupText.
${title.trim().isNotEmpty ? 'Tiêu đề tham khảo: "$title".' : ''}

Yêu cầu:
- Viết bằng tiếng Việt, văn phong phù hợp với nhóm đối tượng
- Độ dài khoảng 3-5 câu
- Sử dụng các biến sau để cá nhân hóa:
  + {{ten}} — tên người nhận
  + {{nam_am}} — tên năm âm lịch (VD: Bính Ngọ)
  + {{nam_duong}} — năm dương lịch (VD: 2026)
  + {{quan_he}} — xưng hô phù hợp
- Chỉ trả về NỘI DUNG lời chúc, không giải thích thêm
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Bạn là trợ lý chuyên viết lời chúc Tết tiếng Việt.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
        throw Exception('Phản hồi từ AI rỗng');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error']?['message'] ?? 'Lỗi không xác định';
        throw Exception('OpenAI API lỗi (${response.statusCode}): $errorMsg');
      }
    } catch (e) {
      debugPrint('OpenAI API error: $e');
      rethrow;
    }
  }
}
