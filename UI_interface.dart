
import 'package:flutter/material.dart';

void main() {
  runApp(SignLanguageApp());
}

class SignLanguageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language Communication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(), // Start with Login first
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static final newBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.black,
        width: 2,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                  'https://static01.nyt.com/images/2024/03/04/crosswords/04gameplay-asl-art/04gameplay-asl-art-googleFourByThree.jpg',
                  fit: BoxFit.cover),
            ),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gesture, size: 90, color: Colors.indigo),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign Language App",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfe1003c8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email_outlined),
                              border: newBorder,
                              enabledBorder: newBorder,
                              focusedBorder: newBorder,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@')) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: newBorder,
                              enabledBorder: newBorder,
                              focusedBorder: newBorder,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login Successful!"),
                                      backgroundColor: Colors.indigo,
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CameraScreen(),
    TextToSignScreen(),
    SignToTextScreen(),
    ProfileScreen(), // Added Profile Page here
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Language App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_fields), label: 'Text → Sign'),
          BottomNavigationBarItem(
              icon: Icon(Icons.gesture), label: 'Sign → Text'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text('Camera feed will appear here', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Open Camera'),
          ),
        ],
      ),
    );
  }
}

class TextToSignScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: 'Enter text to convert to sign language',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Convert'),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            color: Colors.indigo.shade50,
            alignment: Alignment.center,
            child: Text('Sign animation output will appear here'),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////
// SIGN TO TEXT SCREEN
//////////////////////////////////////

class SignToTextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gesture, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text('Sign-to-text recognition coming soon!'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Start Recognition'),
          ),
        ],
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage:
                  AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(height: 15),
            const Text(
              "Uday Sharma",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Flutter Developer • Sign Language Project",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Divider(thickness: 1, color: Colors.indigo.shade100),
            const SizedBox(height: 30),
            ProfileInfoRow(
                icon: Icons.email_outlined,
                title: "Email",
                value: "uday@example.com"),
            ProfileInfoRow(
                icon: Icons.phone_android,
                title: "Phone",
                value: "+91 9876543210"),
            ProfileInfoRow(
                icon: Icons.location_on_outlined,
                title: "Location",
                value: "India"),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoRow(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'Sign Language Communication App\nVersion 1.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'Developed to bridge the communication gap between the hearing and speech-impaired community and others.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
