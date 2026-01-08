import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/user_action_log.dart';
import '../services/database_helper.dart';
import '../services/permission_service.dart';
import '../utils/logger.dart';

/// Provider pour gérer les utilisateurs et leurs actions
class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final PermissionService _permissionService = PermissionService();

  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ============= GETTERS =============

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<User> get activeUsers => _users.where((u) => u.isActive).toList();

  // ============= INITIALISATION =============

  /// Charger tous les utilisateurs
  Future<void> chargerUsers() async {
    try {
      _setLoading(true);
      _clearError();

      _users = await _db.getAllUsers();
      logger.info('✅ ${_users.length} utilisateurs chargés');

      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des utilisateurs: $e');
      _setError('Erreur lors du chargement des utilisateurs');
    } finally {
      _setLoading(false);
    }
  }

  /// Définir l'utilisateur actuel
  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    await _db.updateLastConnection(user.id!);
    notifyListeners();
  }

  /// Définir l'utilisateur actuel par ID
  Future<void> setCurrentUserById(int userId) async {
    final user = await _db.getUserById(userId);
    if (user != null) {
      await setCurrentUser(user);
    }
  }

  /// Définir l'utilisateur actuel par email
  Future<void> setCurrentUserByEmail(String email) async {
    final user = await _db.getUserByEmail(email);
    if (user != null) {
      await setCurrentUser(user);
    }
  }

  /// Initialiser l'utilisateur actuel depuis AuthProvider
  /// Crée un utilisateur par défaut si nécessaire
  Future<void> initializeCurrentUser(String? userId, String? email) async {
    if (userId == null && email == null) {
      logger.warning('⚠️ Aucun identifiant utilisateur disponible');
      return;
    }

    // Charger tous les utilisateurs
    await chargerUsers();

    // Chercher l'utilisateur par email
    User? user;
    if (email != null) {
      user = await _db.getUserByEmail(email);
    }

    // Si aucun utilisateur trouvé, créer un utilisateur par défaut
    if (user == null) {
      final defaultEmail = email ?? 'user_$userId@local.com';
      logger.info('📝 Création d\'un utilisateur par défaut: $defaultEmail');
      
      user = User(
        email: defaultEmail,
        nom: email != null ? email.split('@').first : 'Utilisateur',
        prenom: null,
        role: UserRole.eleveur,
        isActive: true,
        dateCreation: DateTime.now(),
        notes: null,
      );

      final id = await _db.createUser(user);
      user = user.copyWith(id: id);
      logger.info('✅ Utilisateur créé avec ID: $id');
    }

    // Définir comme utilisateur actuel
    await setCurrentUser(user);
    logger.info('✅ Utilisateur actuel initialisé: ${user.email}');
  }

  // ============= CRUD UTILISATEURS =============

  /// Créer un nouvel utilisateur
  Future<bool> creerUser({
    required String email,
    required String nom,
    String? prenom,
    UserRole role = UserRole.eleveur,
    String? photoPath,
    String? notes,
  }) async {
    try {
      _clearError();

      // Vérifier si l'email existe déjà
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        _setError('Un utilisateur avec cet email existe déjà');
        return false;
      }

      final user = User(
        email: email,
        nom: nom,
        prenom: prenom,
        role: role,
        photoPath: photoPath,
        isActive: true,
        dateCreation: DateTime.now(),
        notes: notes,
      );

      final id = await _db.createUser(user);
      logger.info('✅ Utilisateur créé: $id');

      // Enregistrer l'action
      if (_currentUser != null) {
        await logAction(
          ActionType.create,
          'user',
          id,
          description: 'Création de l\'utilisateur $email',
        );
      }

      await chargerUsers();
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la création de l\'utilisateur: $e');
      _setError('Erreur lors de la création de l\'utilisateur');
      return false;
    }
  }

  /// Mettre à jour un utilisateur
  Future<bool> mettreAJourUser(User user) async {
    try {
      _clearError();

      await _db.updateUser(user);
      logger.info('✅ Utilisateur mis à jour: ${user.id}');

      // Enregistrer l'action
      if (_currentUser != null) {
        await logAction(
          ActionType.update,
          'user',
          user.id,
          description: 'Modification de l\'utilisateur ${user.email}',
        );
      }

      // Mettre à jour l'utilisateur actuel si c'est lui
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }

      await chargerUsers();
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour de l\'utilisateur: $e');
      _setError('Erreur lors de la mise à jour de l\'utilisateur');
      return false;
    }
  }

  /// Supprimer un utilisateur (soft delete)
  Future<bool> supprimerUser(int userId) async {
    try {
      _clearError();

      // Ne pas permettre de supprimer l'utilisateur actuel
      if (_currentUser?.id == userId) {
        _setError('Impossible de supprimer l\'utilisateur actuellement connecté');
        return false;
      }

      await _db.deleteUser(userId);
      logger.info('✅ Utilisateur supprimé: $userId');

      // Enregistrer l'action
      if (_currentUser != null) {
        await logAction(
          ActionType.delete,
          'user',
          userId,
          description: 'Suppression de l\'utilisateur $userId',
        );
      }

      await chargerUsers();
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression de l\'utilisateur: $e');
      _setError('Erreur lors de la suppression de l\'utilisateur');
      return false;
    }
  }

  /// Activer un utilisateur
  Future<bool> activerUser(int userId) async {
    try {
      _clearError();

      await _db.activateUser(userId);
      logger.info('✅ Utilisateur activé: $userId');

      // Enregistrer l'action
      if (_currentUser != null) {
        await logAction(
          ActionType.update,
          'user',
          userId,
          description: 'Activation de l\'utilisateur $userId',
        );
      }

      await chargerUsers();
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'activation de l\'utilisateur: $e');
      _setError('Erreur lors de l\'activation de l\'utilisateur');
      return false;
    }
  }

  // ============= PERMISSIONS =============

  /// Vérifier si l'utilisateur actuel peut créer un type d'entité
  bool canCreate(String entityType) {
    if (_currentUser == null) return false;
    return _permissionService.canCreate(_currentUser!.role, entityType);
  }

  /// Vérifier si l'utilisateur actuel peut modifier un type d'entité
  bool canUpdate(String entityType) {
    if (_currentUser == null) return false;
    return _permissionService.canUpdate(_currentUser!.role, entityType);
  }

  /// Vérifier si l'utilisateur actuel peut supprimer un type d'entité
  bool canDelete(String entityType) {
    if (_currentUser == null) return false;
    return _permissionService.canDelete(_currentUser!.role, entityType);
  }

  /// Vérifier si l'utilisateur actuel peut voir un type d'entité
  bool canView(String entityType) {
    if (_currentUser == null) return false;
    return _permissionService.canView(_currentUser!.role, entityType);
  }

  /// Vérifier si l'utilisateur actuel peut exporter
  bool canExport() {
    if (_currentUser == null) return false;
    return _permissionService.canExport(_currentUser!.role);
  }

  /// Vérifier si l'utilisateur actuel peut importer
  bool canImport() {
    if (_currentUser == null) return false;
    return _permissionService.canImport(_currentUser!.role);
  }

  /// Vérifier si l'utilisateur actuel peut gérer les utilisateurs
  bool canManageUsers() {
    if (_currentUser == null) return false;
    return _permissionService.canManageUsers(_currentUser!.role);
  }

  /// Vérifier si l'utilisateur actuel peut modifier les paramètres
  bool canModifySettings() {
    if (_currentUser == null) return false;
    return _permissionService.canModifySettings(_currentUser!.role);
  }

  // ============= LOGS D'ACTIONS =============

  /// Enregistrer une action utilisateur
  Future<void> logAction(
    ActionType actionType,
    String entityType,
    int? entityId, {
    String? description,
    Map<String, dynamic>? details,
  }) async {
    if (_currentUser == null || _currentUser!.id == null) return;

    try {
      final log = UserActionLog(
        userId: _currentUser!.id!,
        actionType: actionType,
        entityType: entityType,
        entityId: entityId,
        description: description,
        details: details,
        dateAction: DateTime.now(),
      );

      await _db.logUserAction(log);
    } catch (e) {
      logger.error('❌ Erreur lors de l\'enregistrement de l\'action: $e');
      // Ne pas bloquer l'application en cas d'erreur de log
    }
  }

  /// Récupérer les logs d'actions de l'utilisateur actuel
  Future<List<UserActionLog>> getMyActionLogs({int? limit}) async {
    if (_currentUser == null || _currentUser!.id == null) return [];
    return await _db.getUserActionLogs(_currentUser!.id!, limit: limit);
  }

  /// Récupérer tous les logs d'actions (admin seulement)
  Future<List<UserActionLog>> getAllActionLogs({int? limit}) async {
    if (!canManageUsers()) return [];
    return await _db.getAllActionLogs(limit: limit);
  }

  /// Récupérer les logs d'actions par période
  Future<List<UserActionLog>> getActionLogsByPeriod(
    DateTime debut,
    DateTime fin,
  ) async {
    if (!canManageUsers()) return [];
    return await _db.getActionLogsByPeriod(debut, fin);
  }

  // ============= GESTION D'ÉTAT =============

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Réinitialiser l'état
  void reset() {
    _users = [];
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

