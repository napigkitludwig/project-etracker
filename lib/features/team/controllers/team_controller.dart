import '../../../core/controllers/base_controller.dart';
import '../../../core/utils/password_hasher.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/models/user_role.dart';
import '../../auth/services/user_local_data_source.dart';

/// Backs the team screen: every account plus the admin-only actions (create,
/// change role, delete). The view hides these controls from other roles; the
/// *permission* enforcement lives here.
class TeamController extends BaseController {
  TeamController({required this.authController, UserLocalDataSource? userStore})
    : _userStore = userStore ?? UserLocalDataSource();

  final AuthController authController;
  final UserLocalDataSource _userStore;

  List<User> _accounts = const <User>[];

  /// Registered accounts. Empty for non-admin users.
  List<User> get accounts => List<User>.unmodifiable(_accounts);

  User? get currentUser => authController.currentUser;

  bool get canManageUsers => currentUser?.role.canManageUsers ?? false;

  /// Number of accounts holding [role].
  int countFor(UserRole role) =>
      _accounts.where((User user) => user.role == role).length;

  /// Whether [userId] belongs to the signed-in user.
  bool isCurrentUser(int? userId) =>
      userId != null && userId == currentUser?.id;

  Future<void> load() async {
    if (!canManageUsers) {
      _accounts = const <User>[];
      notify();
      return;
    }
    final List<User>? result = await runGuarded<List<User>>(
      _userStore.getUsers,
    );
    if (result != null) {
      _accounts = result;
      notify();
    }
  }

  /// Admin-only: creates a new account with a hashed password.
  Future<bool> createUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    if (!canManageUsers) {
      setError('Only administrators can create accounts.');
      return false;
    }
    final String trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      setError('A username and password are required.');
      return false;
    }

    final bool? alreadyTaken = await runGuarded<bool>(
      () => _userStore.usernameExists(trimmedUsername),
    );
    if (alreadyTaken == null) {
      return false; // storage failure, errorMessage already set
    }
    if (alreadyTaken) {
      setError('The username "$trimmedUsername" is already taken.');
      return false;
    }

    final int? newId = await runGuarded<int>(
      () => _userStore.insertUser(
        User(
          username: trimmedUsername,
          password: PasswordHasher.hash(password),
          role: role,
        ),
      ),
    );
    if (newId == null) {
      return false;
    }
    await load();
    return true;
  }

  /// Admin-only: changes [user]'s role. Admins cannot demote themselves, so the
  /// workspace can never lose its last way back in.
  Future<bool> changeRole(User user, UserRole role) async {
    if (!canManageUsers) {
      setError('Only administrators can change roles.');
      return false;
    }
    if (isCurrentUser(user.id)) {
      setError('You cannot change your own role.');
      return false;
    }
    final int? updated = await runGuarded<int>(
      () => _userStore.updateUser(user.copyWith(role: role)),
    );
    if (updated == null) {
      return false;
    }
    await load();
    return true;
  }

  /// Admin-only: deletes the account with [userId].
  Future<bool> deleteUser(int userId) async {
    if (!canManageUsers) {
      setError('Only administrators can delete accounts.');
      return false;
    }
    if (isCurrentUser(userId)) {
      setError('You cannot delete the account you are signed in with.');
      return false;
    }
    final int? deleted = await runGuarded<int>(
      () => _userStore.deleteUser(userId),
    );
    if (deleted == null) {
      return false;
    }
    await load();
    return true;
  }
}
