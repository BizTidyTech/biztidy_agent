import 'package:biztidy_agent_app/app/resources/app_router.dart';
import 'package:biztidy_agent_app/firebase_options.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BizTidyAgentApp());
}

class BizTidyAgentApp extends StatelessWidget {
  const BizTidyAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BizTidy Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryThemeColor),
        useMaterial3: false,
        fontFamily: 'OpenSans',
      ),
      routerConfig: AgentAppRouter.router,
    );
  }
}
