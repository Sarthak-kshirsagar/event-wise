import '../../data/models/AuthModel.dart';

abstract class EventWiseAuthenticationService {
  Future<void> register({required AuthModel userCred});
  Future<String?> login({required AuthModel userCred});
  Future<void> logout();

}
