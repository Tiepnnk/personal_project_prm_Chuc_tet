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

  /// Gọi OpenAI ChatCompletion API để gợi ý nội dung lời chúc Tết cá nhân hóa
  /// [contactName] — tên người nhận
  /// [relationship] — mối quan hệ (VD: 'Gia đình', 'Sếp', 'Bạn bè')
  /// [templateContent] — nội dung mẫu lời chúc (optional, nếu có thì AI viết dựa trên mẫu)
  Future<String> generateWishContent({
    required String contactName,
    required String relationship,
    String? templateContent,
  }) async {
    final hasTemplate = templateContent != null && templateContent.trim().isNotEmpty;

    final prompt = '''
Bạn là chuyên gia viết lời chúc Tết Nguyên Đán bằng tiếng Việt cho năm nay 2026, Bính Ngọ.
Hãy viết một lời chúc Tết chân thành, cá nhân hóa cho người nhận.

Thông tin người nhận:
- Tên: $contactName
- Mối quan hệ: $relationship

${hasTemplate ? 'Mẫu lời chúc tham khảo (hãy viết lại dựa trên mẫu này nhưng cá nhân hóa cho phù hợp):\n"""$templateContent"""' : ''}

Yêu cầu:
- Viết bằng tiếng Việt, văn phong phù hợp với mối quan hệ "$relationship"
- Xưng hô phù hợp (VD: con-bố/mẹ, em-anh/chị/sếp, tôi-bạn...)
- Đề cập trực tiếp tên "$contactName" trong lời chúc
- Độ dài khoảng 3-5 câu
- Lời chúc phải tự nhiên, chân thành, không sáo rỗng
${hasTemplate ? '- PHẢI dựa trên nội dung mẫu đã cho để viết lại, giữ ý chính nhưng cá nhân hóa' : ''}
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
            {'role': 'system', 'content': 'Bạn là trợ lý chuyên viết lời chúc Tết tiếng Việt cá nhân hóa.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.85,
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

  /// Gọi OpenAI ChatCompletion API để gợi ý nội dung lời chúc Tết cho NHÓM người
  /// [relationship] — mối quan hệ (VD: 'Gia đình', 'Bạn bè')
  /// [memberCount] — số lượng người trong nhóm
  /// [templateContent] — nội dung mẫu lời chúc (optional)
  Future<String> generateGroupWishContent({
    required String relationship,
    required int memberCount,
    String? templateContent,
  }) async {
    final hasTemplate = templateContent != null && templateContent.trim().isNotEmpty;

    final prompt = '''
Bạn là chuyên gia viết lời chúc Tết Nguyên Đán bằng tiếng Việt cho năm nay 2026 , Bính Ngọ.
Hãy viết một lời chúc Tết chung, chân thành cho một nhóm gồm $memberCount người.

Thông tin nhóm:
- Mối quan hệ chung: $relationship

${hasTemplate ? 'Mẫu lời chúc tham khảo (hãy viết lại dựa trên mẫu này cho phù hợp với số nhiều):\n"""$templateContent"""' : ''}

Yêu cầu:
- Viết bằng tiếng Việt, văn phong phù hợp với mối quan hệ "$relationship"
- Xưng hô phù hợp số nhiều (VD: các bạn, anh chị em, gia đình mình...)
- KHÔNG nhắc đến tên riêng cụ thể nào vì đây là lời chúc gửi chung cho nhiều người
- Độ dài khoảng 3-5 câu
- Lời chúc phải tự nhiên, chân thành, không sáo rỗng
${hasTemplate ? '- PHẢI dựa trên nội dung mẫu đã cho để viết lại, giữ ý chính nhưng điều chỉnh thành lời chúc chung cho nhóm' : ''}
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
            {'role': 'system', 'content': 'Bạn là trợ lý chuyên viết lời chúc Tết tiếng Việt cho nhóm người.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.85,
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
