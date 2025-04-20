import 'package:btech/domain/repositories/auth_repo.dart';
import 'package:btech/infrastructure/firebase/auth_service.dart';

import '../../data/models/AuthModel.dart';

class AuthViewModel {
  final EventWiseAuthenticationService authRepo;


  AuthViewModel({required this.authRepo});

  Future<String?> login(AuthModel user) async {
    try {
      String? result = await authRepo.login(userCred: user);
      return result;
    } catch (e) {
      print("caught the error");
      return e.toString();
    }
  }

  Future<String?> register(AuthModel user) async {
    try {
      await authRepo.register(userCred: user);
      return 'success';
    } catch (e) {
      print("Error");
      print(e);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await authRepo.logout();
  }
}
