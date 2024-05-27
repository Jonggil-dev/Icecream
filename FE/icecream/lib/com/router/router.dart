import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/auth/screen/c_qrcode.dart';
import 'package:icecream/auth/screen/fork_page.dart';
import 'package:icecream/auth/screen/p_login_page.dart';
import 'package:icecream/auth/screen/p_signup.dart';
import 'package:icecream/auth/screen/qrscan_page.dart';
import 'package:icecream/child/screen/child_overspeed1.dart';
import 'package:icecream/child/screen/child_overspeed2.dart';
import 'package:icecream/child/screen/child_overspeed3.dart'; // 빨간색 버블
import 'package:icecream/com/widget/temp.dart';
import 'package:icecream/home/screen/c_home.dart';
import 'package:icecream/home/screen/p_home.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/provider/destination_provider.dart';
import 'package:icecream/setting/screen/child_detail_screen.dart';
import 'package:icecream/setting/screen/child_screen.dart';
import 'package:icecream/setting/screen/destination_screen.dart';
import 'package:icecream/setting/screen/map_screen.dart';
import 'package:icecream/setting/screen/my_page.dart';
import 'package:icecream/setting/screen/search_screen.dart';
import 'package:icecream/setting/screen/setting.dart';
import 'package:icecream/setting/widget/kpostal_wrapper.dart';
import 'package:kpostal/kpostal.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _initialRedirectPerformed = false;

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 자동 로그인이 완료된 후에는 리디렉션을 수행하지 않도록 함
    if (_initialRedirectPerformed) {
      return null;
    }

    // 자동 로그인 후 첫 리디렉션 처리
    if (!userProvider.isLoggedIn) {
      _initialRedirectPerformed = true;
      return '/';
    } else if (userProvider.isParent) {
      _initialRedirectPerformed = true;
      return '/p_login/parents';
    } else {
      _initialRedirectPerformed = true;
      return '/child';
    }
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const ForkPage();
      },
      routes: [
        GoRoute(
          name: 'overspeed1',
          path: 'overspeed1',
          builder: (context, state) => const Overspeed1(),
        ),
        GoRoute(
          name: 'overspeed2',
          path: 'overspeed2',
          builder: (context, state) => const Overspeed2(),
        ),
        GoRoute(
          name: 'overspeed3',
          path: 'overspeed3',
          builder: (context, state) => const Overspeed3(),
        ),
        GoRoute(
          name: 'signup',
          path: 'signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          name: 'p_login',
          path: 'p_login',
          builder: (context, state) => const LoginPage(),
          routes: [
            GoRoute(
                name: 'qrscan_page',
                path: 'qrscan_page',
                builder: (context, state) => const QRScanPage()),
            GoRoute(
              name: 'parents',
              path: 'parents',
              builder: (context, state) => const PHome(),
            ),

            // setting 페이지
            GoRoute(
              path: 'setting',
              name: 'setting',
              builder: (context, state) => const Setting(),
              routes: [
                // setting 페이지의 마이페이지
                GoRoute(
                  path: 'my_page',
                  name: 'my_page',
                  builder: (context, state) => const MyPage(),
                ),
                // setting 페이지의 자녀 관리 페이지
                GoRoute(
                  path: 'children',
                  name: 'children',
                  builder: (context, state) => const ChildScreen(),
                  routes: [
                    // setting의 자녀 1명 페이지
                    GoRoute(
                      path: 'child/:user_id',
                      name: 'child',
                      builder: (context, state) {
                        final userId =
                            int.parse(state.pathParameters['user_id']!);
                        return ChildDetailScreen(
                          user_id: userId,
                        );
                      },
                      routes: [
                        GoRoute(
                            path: 'destination',
                            name: 'destination',
                            builder: (context, state) {
                              // patch에서 넘어오는 data 고려
                              final data =
                                  state.extra as Map<String, dynamic>? ?? null;
                              return DestinationScreen(
                                user_id:
                                    int.parse(state.pathParameters['user_id']!),
                                data: data,
                              );
                            },
                            routes: [
                              GoRoute(
                                path: 'query_parameter',
                                name: 'search',
                                builder: (context, state) {
                                  final user_id = int.parse(
                                      state.pathParameters['user_id']!);
                                  return SearchScreen(user_id: user_id);
                                },
                              ),
                              GoRoute(
                                path: 'map',
                                name: 'map',
                                builder: (context, state) {
                                  final user_id = int.parse(
                                      state.pathParameters['user_id']!);
                                  return MapScreen(user_id: user_id);
                                },
                              ),
                              GoRoute(
                                path: 'kpostal',
                                name: 'kpostal',
                                builder: (context, state) {
                                  final user_id = int.parse(
                                      state.pathParameters['user_id']!);
                                  return KpostalWrapper(user_id: user_id);
                                },
                              ),
                            ]),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'c_qrcode',
          name: 'c_qrcode',
          builder: (context, state) => const QRCodePage(),
        ),
        GoRoute(
          path: 'child',
          builder: (context, state) => const CHome(),
        ),
      ],
    ),
  ],
);
