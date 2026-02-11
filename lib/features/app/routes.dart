import 'package:chronoflow/features/auth/presentation/pages/login_page.dart';
import 'package:chronoflow/features/counter/counter_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  GoRouter generateRoute() => GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        name: 'counter',
        builder: (context, state) => const CounterPage(
          title: 'Counter Page',
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
