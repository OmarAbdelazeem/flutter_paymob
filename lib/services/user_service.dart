import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _userIdKey = 'user_id';

/// Provides a stable user id per install for saved-cards API (X-User-Id).
/// Uses SharedPreferences + UUID; replace with real auth in production.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  String? _userId;

  /// Returns the current user id. Call [ensureInitialized] from main() first.
  String get userId {
    final id = _userId;
    if (id == null || id.isEmpty) {
      throw StateError('UserService not initialized. Call ensureInitialized() from main() before runApp.');
    }
    return id;
  }

  /// Call once before runApp. Loads or creates userId and stores it.
  static Future<void> ensureInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_userIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_userIdKey, id);
    }
    instance._userId = id;
  }
}
