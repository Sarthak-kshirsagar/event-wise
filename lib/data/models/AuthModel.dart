class AuthModel{
  String name = '';
  String email =  '';
  String password = '';
  AuthModel({required this.name,required email, required password}){
    this.email = email;
    this.password = password;
    this.name = name;
  }
}