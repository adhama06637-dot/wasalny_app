import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Home.dart';
import 'screens/RideSharing_screen.dart';
import 'screens/my_rides_screen.dart';
import 'Login_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const ProfilePage());
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luxury Profile App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffFBFBFF), // Main screen background
        primaryColor: const Color(0xFF6C63FF), // Accent color
        fontFamily: 'Montserrat', // You would need to add this font to use it
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFF),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(
              Icons.notifications_off_outlined,
              size: 90,
              color: Colors.grey,
            ),

            SizedBox(height: 15),

            Text(
              "No Notifications Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "You’ll see updates about your rides here",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _msg(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFF),
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "How can we help you?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          _card(
            icon: Icons.email_outlined,
            title: "Email Support",
            subtitle: "support@wasalny.com",
            onTap: () => _msg(context, "Opening email..."),
          ),

          _card(
            icon: Icons.phone_outlined,
            title: "Call Us",
            subtitle: "+20 XXX XXX XXXX",
            onTap: () => _msg(context, "Calling support..."),
          ),

          _card(
            icon: Icons.chat_outlined,
            title: "Live Chat",
            subtitle: "Talk to support team",
            onTap: () => _msg(context, "Chat coming soon"),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showMsg(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFF),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Account",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _tile(
            context,
            icon: Icons.person,
            title: "Edit Profile",
            subtitle: "Change your name & info",
            onTap: () => _showMsg(context, "Edit Profile coming soon"),
          ),

          _tile(
            context,
            icon: Icons.lock,
            title: "Privacy",
            subtitle: "Security settings",
            onTap: () => _showMsg(context, "Privacy settings coming soon"),
          ),

          const SizedBox(height: 20),

          const Text(
            "App",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _tile(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Manage alerts",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
          ),

          _tile(
            context,
            icon: Icons.language,
            title: "Language",
            subtitle: "Change app language",
            onTap: () => _showMsg(context, "Language coming soon"),
          ),

          const SizedBox(height: 20),

          _tile(
            context,
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Sign out from account",
            isDanger: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logged out")),
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDanger ? Colors.red : const Color(0xFF6C63FF),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 4; // Set to Profile (last item)
 String _userName = "Loading...";

 Future<void> _loadUserData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

     if (doc.exists) {
  final data = doc.data();

  setState(() {
    _userName =
        "${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}";
  });
} else {
  setState(() {
    _userName = "User";
  });
}
    }
  } catch (e) {
    print(e);
  }
}

@override
void initState() {
  super.initState();
  _loadUserData();
}

String getInitials(String name) {
  if (name.trim().isEmpty) return "U";

  List<String> names = name.trim().split(' ');

  if (names.length >= 2) {
    return "${names[0][0]}${names[1][0]}".toUpperCase();
  }

  return names[0][0].toUpperCase();
}

  // Helper method to build the menu tiles
  Widget _buildProfileMenuItem({
    required IconData iconData,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDanger ? const Color(0xffFFF2F2) : const Color(0xffF2F0FF), // Light background for icons
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626), // Dark text for titles
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }

  // Method to handle name editing
  void _editUserName() {
    TextEditingController controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit User Name"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userName = controller.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User name updated!')),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Method to show a snackbar for unimplemented features to give a feel of working buttons
  void _showUnimplementedMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colors from the design image
    const Color primaryPurpleDark = Color(0xFF5428B7);
    const Color primaryPurpleLight = Color(0xFF7A4CFF);
    const Color mainIconColor = Color(0xFF6C63FF);

    return Scaffold(
      extendBody: true, // For transparent bottom bar, though we don't have that here
      body: Stack(
        children: [
          // 1. Purple Gradient Top Section with curve
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurpleDark, primaryPurpleLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // No notification bell here as requested.

          // 2. Profile Area and Main Card
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Avatar Stack
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0), // Outer white border
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                       child: CircleAvatar(
  radius: 60,
  backgroundColor: Colors.white,
  child: Text(
    _userName == "Loading..."
        ? "..."
        : getInitials(_userName),
    style: const TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.bold,
      color: Color(0xFF6C63FF),
    ),
  ),
),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _editUserName, // Working edit button
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: mainIconColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and Welcome text
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "Welcome back 👋",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main Menu Card
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent, // Disable material3 surface color
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildProfileMenuItem(
                            iconData: Icons.person_outline,
                            iconColor: mainIconColor,
                            title: "Edit User Name",
                            subtitle: "Update your name",
                            onTap: _editUserName, // Working functionality
                          ),
                          _buildProfileMenuItem(
  iconData: Icons.history,
  iconColor: mainIconColor,
  title: "Ride History",
  subtitle: "View your past rides",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRidesScreen(),
      ),
    );
  },
),
                          _buildProfileMenuItem(
                            iconData: Icons.notifications_none,
                            iconColor: mainIconColor,
                            title: "Notification",
                            subtitle: "Manage your alerts",
                           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NotificationsScreen(),
    ),
  );
},
                          ),
                          _buildProfileMenuItem(
                            iconData: Icons.headset_mic_outlined,
                            iconColor: mainIconColor,
                            title: "Support",
                            subtitle: "Get help and support",
                           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SupportScreen(),
    ),
  );
},
                          ),
                          _buildProfileMenuItem(
                            iconData: Icons.settings_outlined,
                            iconColor: mainIconColor,
                            title: "Settings",
                            subtitle: "Manage your preferences",
                            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ),
  );
},
                          ),
                          _buildProfileMenuItem(
                            iconData: Icons.logout,
                            iconColor: const Color(0xffFF6B6B), // Reddish icon
                            title: "Log out",
                            subtitle: "Sign out from your account",
                            onTap: () async {
  final logout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Logout"),
        ),
      ],
    ),
  );

  if (logout == true) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
},
                           
                            isDanger: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
       top: false,
       child: _buildBottomNavigationBar(),
),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Home
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.home_outlined ,
              label: 'Home',
              isActive: false,
            ),
          ),

          // Ride Sharing
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RideSharingScreen(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.directions_car_outlined,
              label: 'Ride Sharing',
              isActive: false,
            ),
          ),

          // My Rides
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyRidesScreen(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.list_alt_outlined,
              label: 'My Rides',
              isActive: false,
            ),
          ),

          // Profile
          GestureDetector(
            onTap: () {},
            child: _buildNavItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
