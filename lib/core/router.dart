import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/reset_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/detail/detail_screen.dart';
import '../presentation/screens/watchlist/watchlist_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home - dikerjakan Anggota 4')),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login - dikerjakan Anggota 2')),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register - dikerjakan Anggota 2')),
        ),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Detail - dikerjakan Anggota 5')),
        ),
      ),
      GoRoute(
        path: '/film/tambah',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Form Tambah - dikerjakan Anggota 4')),
        ),
      ),
      GoRoute(
        path: '/film/edit/:id',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Form Edit - dikerjakan Anggota 5')),
        ),
      ),
      GoRoute(
        path: '/watchlist',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Watchlist - dikerjakan Anggota 4')),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile - dikerjakan Anggota 2')),
        ),
      ),
    ],
  );
});