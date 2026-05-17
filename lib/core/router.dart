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
import '../presentation/screens/tambah_film/tambah_film_screen.dart';

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
      // ── Anggota 4 (Faqih) ─────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/film/tambah',
        builder: (context, state) => const TambahFilmScreen(),
      ),
      GoRoute(
        path: '/watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),

      // ── Anggota 2 (Kelvin) ────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // ── Anggota 5 (Galank) ────────────────────────────
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) => const DetailScreen(),
      ),
      GoRoute(
        path: '/film/edit/:id',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Form Edit - dikerjakan Anggota 5')),
        ),
      ),

      // ── Anggota 2 (Kelvin) ────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile - dikerjakan Anggota 2')),
        ),
      ),
    ],
  );
});