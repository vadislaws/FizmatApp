import 'package:firebase_core/firebase_core.dart';
import 'package:fizmat_app/firebase_options.dart';
import 'package:fizmat_app/l10n/app_localizations.dart';
import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/providers/kundelik_provider.dart';
import 'package:fizmat_app/providers/locale_provider.dart';
import 'package:fizmat_app/providers/theme_provider.dart';
import 'package:fizmat_app/models/user_model.dart';
import 'package:fizmat_app/screens/auth/code_verification_screen.dart';
import 'package:fizmat_app/screens/auth/email_verification_screen.dart';
import 'package:fizmat_app/screens/auth/fizmat_email_input_screen.dart';
import 'package:fizmat_app/screens/auth/forgot_password_screen.dart';
import 'package:fizmat_app/screens/auth/login_screen.dart';
import 'package:fizmat_app/screens/auth/register_screen.dart';
import 'package:fizmat_app/screens/birthday/birthday.dart';
import 'package:fizmat_app/screens/friends/friends_list_screen.dart';
import 'package:fizmat_app/screens/functions/functions_menu.dart';
import 'package:fizmat_app/screens/home/home.dart';
import 'package:fizmat_app/screens/kundelik/kundelik_connect_screen.dart';
import 'package:fizmat_app/screens/login/login.dart';
import 'package:fizmat_app/screens/profile/profile.dart';
import 'package:fizmat_app/screens/profile/user_profile_screen.dart';
import 'package:fizmat_app/screens/splash/splash_screen.dart';
import 'package:fizmat_app/screens/timetb/timetb.dart';
import 'package:fizmat_app/widgets/fiz_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KundelikProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Fizmat App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode == AppThemeMode.system
                ? ThemeMode.system
                : themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('kk'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/splash',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/splash':
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  );
                case '/register':
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  );
                case '/forgot_password':
                  return MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  );
                case '/email_verification':
                  return MaterialPageRoute(
                    builder: (_) => const EmailVerificationScreen(),
                  );
                case '/old_login':
                  return MaterialPageRoute(
                    builder: (_) => const FizLogin(),
                  );
                case '/fizmat_email_input':
                  return MaterialPageRoute(
                    builder: (_) => const FizmatEmailInputScreen(),
                  );
                case '/code_verification':
                  final email = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => CodeVerificationScreen(email: email),
                  );
                case '/FizNavBar':
                  return MaterialPageRoute(
                    builder: (_) => const FizNavBar(
                      pages: [
                        FizHome(),
                        FunctionsMenu(),
                        FizProfile(),
                      ],
                    ),
                  );
                case '/FizHome':
                  return MaterialPageRoute(builder: (_) => const FizHome());
                case '/FizTimetb':
                  return MaterialPageRoute(builder: (_) => const FizTimetb());
                case '/FizBirthday':
                  return MaterialPageRoute(
                      builder: (_) => const FizBirthday());
                case '/FizProfile':
                  return MaterialPageRoute(
                      builder: (_) => const FizProfile());
                case '/kundelik-connect':
                  return MaterialPageRoute(
                      builder: (_) => const KundelikConnectScreen());
                case '/friends':
                  return MaterialPageRoute(
                      builder: (_) => const FriendsListScreen());
                case '/user-profile':
                  final user = settings.arguments as UserModel;
                  return MaterialPageRoute(
                      builder: (_) => UserProfileScreen(user: user));
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}

