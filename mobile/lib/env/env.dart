import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'STREAM_CHAT_API_KEY', obfuscate: true)
  static final streamChatApiKey = _Env.streamChatApiKey;
}