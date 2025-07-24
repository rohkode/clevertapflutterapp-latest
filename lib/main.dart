// ignore_for_file: avoid_print

import 'dart:io';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// Deep Link Format:
// Internal: myapp://details (offers or promos)
// Universal: https://ct-web-sdk-react.vercel.app/details (offers or promos)

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
      initialRoute: '/',
      routes: {
        '/': (_) => const MyHomePage(title: 'CleverTap Flutter Project'),
        '/details': (_) => const DetailsScreen(),
        '/offers': (_) => const OffersScreen(),
        '/promo': (_) => const PromoScreen(),
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
  final CleverTapPlugin _clevertapPlugin = CleverTapPlugin();
  static const platform = MethodChannel('myChannel');

  final _identityController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _lastHandledLink;

  @override
  void initState() {
    super.initState();
    _initializeCleverTap();
    _setupPushHandlers();
    _listenToMethodChannelLinks();
    _listenToUniLinks();
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

  void _showPushPrimer() {
    var pushPrimerJSON = {
      'inAppType': 'half-interstitial',
      'titleText': 'Get Notified',
      'messageText': 'Please enable notifications to use Push Notifications.',
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

  void _setupPushHandlers() {
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler((payload) {
      print("Push Clicked Payload: $payload");
      final deepLink = payload['deep_link'] ?? payload['wzrk_dl'];
      if (deepLink != null && deepLink.isNotEmpty) {
        _handleDeepLink(deepLink, isFromPush: true);
      }
    });
  }

  void _listenToMethodChannelLinks() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "handleDeepLink") {
        String? deepLink = call.arguments as String?;
        if (deepLink != null) {
          _handleDeepLink(deepLink, isFromPush: false);
        }
      }
    });
  }

  void _listenToUniLinks() {
    getInitialUri().then((uri) {
      if (uri != null) _handleDeepLink(uri.toString(), isFromPush: false);
    });
    uriLinkStream.listen((uri) {
      if (uri != null) _handleDeepLink(uri.toString(), isFromPush: false);
    }, onError: (err) {
      print("UniLinks error: $err");
    });
  }

  void _handleDeepLink(String link, {required bool isFromPush}) {
    if (link == _lastHandledLink) return;
    _lastHandledLink = link;

    print("Handling Deep Link: $link");
    final uri = Uri.parse(link);

    bool isInternal = link.startsWith("myapp://");
    String? route;

    if (uri.path.contains("details")) route = '/details';
    if (uri.path.contains("offers")) route = '/offers';
    if (uri.path.contains("promo")) route = '/promo';

    if (isInternal) {
    // Show AlertDialog for internal links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => AlertDialog(
          title: const Text("Internal Deep Link Triggered"),
          content: Text("Received: $link"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(navigatorKey.currentContext!).pop();
                if (route != null) {
                  navigatorKey.currentState?.pushNamed(route);
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  } else if (route != null) {
    // Universal link → Navigate properly
    if (isFromPush) {
      navigatorKey.currentState?.pushNamed(route);
    } else {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (r) => r.isFirst);
    }
  } else {
    _showSnackBar("Unknown deep link: $link");
  }
}

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
        );
      }
    });
  }

  void _showAppInbox() {
    CleverTapPlugin.showInbox({
      'title': 'App Inbox',
      'tabs': ['Offers', 'Promotions'],
      'backgroundColor': '#FFFFFF',
      'titleColor': '#000000',
      'messageColor': '#000000',
      'buttonBorderColor': '#000000',
      'buttonBackgroundColor': '#000000',
      'buttonTextColor': '#FFFFFF',
      'noMessageText': 'No Messages',
      'noMessageTextColor': '#000000',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.deepPurple, actions: [
        IconButton(icon: const Icon(Icons.mail_outline, color: Colors.white), onPressed: _showAppInbox),
      ]),
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
      child: TextField(controller: controller, decoration: InputDecoration(border: OutlineInputBorder(), labelText: labelText, hintText: hintText)),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.deepPurple),
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
    var profile = {'Sports': 'Rugby', 'Team': 'All Blacks', 'MVP': 'Jonah Lomu', 'DOB': '2012-04-22', 'Gender': 'M'};
    CleverTapPlugin.profileSet(profile);
  }

  void _recordProductViewed() => CleverTapPlugin.recordEvent("Product Viewed Flutter", {});
  void _recordEvent() => CleverTapPlugin.recordEvent("Product Viewed Flutter Properties", {'Product Category': 'Appliances', 'Product Name': 'Microwave'});
  void _recordChargedEvent() {
    var chargeDetails = {'Amount': 300, 'Payment Mode': 'Credit Card', 'Charged ID': 'Order123'};
    var items = [{'Category': 'Books', 'Product Name': 'Harry Potter', 'Quantity': 1}, {'Category': 'Electronics', 'Product Name': 'Bluetooth Speaker', 'Quantity': 2}];
    CleverTapPlugin.recordChargedEvent(chargeDetails, items);
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Details")), body: const Center(child: Text("Details Screen!")));
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Offers")), body: const Center(child: Text("Offers Screen!")));
}

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Promotions")), body: const Center(child: Text("Promotions Screen!")));
}
