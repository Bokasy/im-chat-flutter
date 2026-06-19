part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const QRCODE_LOGIN = '/qrcode-login';
  static const CHAT_LIST = '/chat';
  static const CHAT_DETAIL = '/chat/detail';
  static const MESSAGE_SEARCH = '/chat/search';
  static const CONTACT_LIST = '/contact';
  static const NEW_FRIEND = '/contact/new-friend';
  static const GROUP_CREATE = '/contact/group-create';
  static const USER_CARD = '/contact/user-card';
  static const PROFILE = '/profile';
}
