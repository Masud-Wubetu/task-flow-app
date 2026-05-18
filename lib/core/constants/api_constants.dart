class ApiConstants {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';
  static const todos   = '/todos';
  static const users   = '/users';

  static String todoById(int id) => '/todos/$id';
}
