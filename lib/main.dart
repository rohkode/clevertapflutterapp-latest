// ignore_for_file: avoid_print

import 'dart:io';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CleverTap Flutter Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CleverTap Flutter Project'),
      routes: {
    '/details': (_) => const DetailsScreen(), // define your route
  },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final CleverTapPlugin _clevertapPlugin = CleverTapPlugin();

  @override
  void initState() {
    super.initState();
    _initializeCleverTap();
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(pushClickedPayloadReceived);

  }

  void _initializeCleverTap() {
    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.createNotificationChannel(
      "fluttertestapp",
      "Flutter Test",
      "Flutter Test Notifications",
      5,
      true,
    );
    CleverTapPlugin.initializeInbox();
    CleverTapPlugin.enablePersonalization();
    CleverTapPlugin.setOptOut(false);
    CleverTapPlugin.enableDeviceNetworkInfoReporting(true);
    CleverTapPlugin.setLocation(19.07, 72.87);
    _showPushPrimer();
  }

  // Future<dynamic> _platformCallHandler(MethodCall call) async {
  //   switch (call.method) {
  //     case 'pushClickedPayloadReceived':
  //       final Map<String, dynamic> payload = Map<String, dynamic>.from(call.arguments);
  //       print("Push Clicked Payload: $payload");

  //       if (payload.containsKey('wzrk_dl') &&
  //           payload['wzrk_dl'] != null &&
  //           payload['wzrk_dl'].toString().isNotEmpty) {
  //         final deepLink = payload['wzrk_dl'];
  //         print("Deep Link: $deepLink");

  //         // Basic route matching for demonstration
  //         if (deepLink == 'myapp://screen/details') {
  //           navigatorKey.currentState?.pushNamed('/details');
  //         }
  //       } else {
  //         print("No deep link in payload");
  //       }
  //       break;

  //     default:
  //       print("Unknown method ${call.method}");
  //   }
  // }

  void _showPushPrimer() {
    var pushPrimerJSON = {
      'inAppType': 'half-interstitial',
      'titleText': 'Get Notified',
      'messageText': 'Please enable notifications on your device to use Push Notifications.',
      'followDeviceOrientation': false,
      'positiveBtnText': 'Allow',
      'negativeBtnText': 'Cancel',
      'fallbackToSettings': true,
      'backgroundColor': '#FFFFFF',
      'btnBorderColor': '#000000',
      'titleTextColor': '#000000',
      'messageTextColor': '#000000',
      'btnTextColor': '#000000',
      'btnBackgroundColor': '#FFFFFF',
      'btnBorderRadius': '4',
      'imageUrl': 'https://logowik.com/content/uploads/images/clevertap5229.jpg'
    };

    CleverTapPlugin.promptPushPrimer(pushPrimerJSON);
  }

  void pushClickedPayloadReceived(Map<String, dynamic> payload) {
  print("Push Clicked Payload: $payload");

  // Check if the deep link is in the payload
  String? deepLink = payload['deep_link'] ?? payload['wzrk_dl']; // Assuming payload contains 'deep_link' key

  if (deepLink != null && deepLink.isNotEmpty) {
      _handleDeepLink(deepLink);
    } else {
      // Handle cases where there is no deep link
      print("No deep link in payload");
    }
  }

  // Handle the deep link and navigate to the respective screen
  void _handleDeepLink(String deepLink) {
    // Display the deep link as an alert
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Deep Link Triggered"),
        content: Text("Received Deep Link: $deepLink"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildTextField('Enter Identity', 'Enter Your Identity', _identityController),
            _buildTextField('Enter Full Name', 'Enter Your Full Name', _nameController),
            _buildTextField('Enter Email', 'Enter Your Email ID', _emailController),
            _buildTextField('Enter Phone', 'Enter Your Phone Number', _phoneController),
            _buildButton('On User Login Flutter', _onUserLogin),
            _buildButton("Profile Set Flutter", _updateUserProfile),
            _buildButton('Event Without Properties Flutter', _recordProductViewed),
            _buildButton('Event With Properties Flutter', _recordEvent),
            _buildButton('Charged Event Flutter', _recordChargedEvent),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  void _onUserLogin() {
    var profile = {
      'Name': _nameController.text,
      'Identity': _identityController.text,
      'Email': _emailController.text,
      'Phone': _phoneController.text,
      'MSG-whatsapp': true,
      'MSG-push': true,
    };
    CleverTapPlugin.onUserLogin(profile);
  }

  void _updateUserProfile() {
    var dob = "2012-04-22";
    var gender = 'M';

    var profile = {
      'Sports': 'Rugby',
      'Team': 'New Zealand All Blacks',
      'MVP': 'Jonah Lomu',
      'DOB': dob,
      'Gender': gender,
    };

    CleverTapPlugin.profileSet(profile);
  }


  void _recordProductViewed() {
    CleverTapPlugin.recordEvent("Product Viewed Flutter", {});
  }

  void _recordEvent() {
    var eventData = {
      'Product Category': 'Appliances',
      'Product Name': 'Convection Microwave Oven'
    };
    CleverTapPlugin.recordEvent("Product Viewed Flutter Properties", eventData);
  }

  }
  void _recordChargedEvent() {
    var chargeDetails = {
      'Amount': 300,
      'Payment Mode': 'Credit Card',
      'Charged ID': 'Order123'
    };

    var items = [
      {
        'Category': 'Books',
        'Product Name': 'Harry Potter',
        'Quantity': 1
      },
      {
        'Category': 'Electronics',
        'Product Name': 'Bluetooth Speaker',
        'Quantity': 2
      }
    ];

    CleverTapPlugin.recordChargedEvent(chargeDetails, items);
  }

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details Screen"),
      ),
      body: const Center(
        child: Text("Welcome to the Details Screen!"),
      ),
    );
  }
}