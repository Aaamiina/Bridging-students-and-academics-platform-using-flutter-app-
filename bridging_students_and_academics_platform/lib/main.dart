import 'package:bridging_students_and_academics_platform/Admin/GMPage.dart';
import 'package:bridging_students_and_academics_platform/Admin/admin_dashboard.dart';
import 'package:bridging_students_and_academics_platform/Login.dart';

import 'package:bridging_students_and_academics_platform/getStarted.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
     theme: ThemeData(
    fontFamily: 'InriaSerif',
  ),
    debugShowCheckedModeBanner: false,
    initialRoute: '/start', 
    routes: {
      "/start" :(context)=> GetStartedPage(),
      '/login': (context) => LoginPage(),
     '/group-members': (context) => const GroupMembersPage(),
      '/admin_dashboard': (context) => const AdminDashboard(),

    

    },
  ));
} 

