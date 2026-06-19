import 'package:get/get.dart';
import 'package:im_flutter/screens/login/login_page.dart';
import 'package:im_flutter/screens/login/register_page.dart';
import 'package:im_flutter/screens/login/qrcode_login_page.dart';
import 'package:im_flutter/screens/chat/chat_list_page.dart';
import 'package:im_flutter/screens/chat/chat_detail_page.dart';
import 'package:im_flutter/screens/chat/message_search_page.dart';
import 'package:im_flutter/screens/contact/contact_list_page.dart';
import 'package:im_flutter/screens/contact/new_friend_page.dart';
import 'package:im_flutter/screens/contact/group_create_page.dart';
import 'package:im_flutter/screens/contact/user_card_page.dart';
import 'package:im_flutter/screens/profile/profile_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.QRCODE_LOGIN,
      page: () => const QRCodeLoginPage(),
    ),
    GetPage(
      name: Routes.CHAT_LIST,
      page: () => const ChatListPage(),
    ),
    GetPage(
      name: Routes.CHAT_DETAIL,
      page: () => const ChatDetailPage(),
    ),
    GetPage(
      name: Routes.MESSAGE_SEARCH,
      page: () => const MessageSearchPage(),
    ),
    GetPage(
      name: Routes.CONTACT_LIST,
      page: () => const ContactListPage(),
    ),
    GetPage(
      name: Routes.NEW_FRIEND,
      page: () => const NewFriendPage(),
    ),
    GetPage(
      name: Routes.GROUP_CREATE,
      page: () => const GroupCreatePage(),
    ),
    GetPage(
      name: Routes.USER_CARD,
      page: () => const UserCardPage(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
    ),
  ];
}
