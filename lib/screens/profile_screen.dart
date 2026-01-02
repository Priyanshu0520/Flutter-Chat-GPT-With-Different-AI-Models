import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/widgets/build_display_image.dart';
import 'package:chatbotapp/widgets/settings_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userImage = '';
  String userName = 'Guest';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  static const Color primaryColor = Color.fromARGB(255, 174, 128, 72);
  static const Color secondaryColor = Color.fromARGB(255, 168, 93, 58);

  void pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          file = File(pickedImage.path);
        });
        saveUserImage(pickedImage.path);
      }
    } catch (e) {
      log('error : $e');
    }
  }

  void saveUserImage(String imagePath) {
    final userBox = Boxes.getUser();
    if (userBox.isNotEmpty) {
      final user = userBox.getAt(0);
      final updatedUser = UserModel(
        name: user!.name,
        image: imagePath,
        uid: user.uid,
      );
      userBox.putAt(0, updatedUser);
      setState(() {
        userImage = imagePath;
      });
    } else {
      final newUser = UserModel(
        name: userName,
        image: imagePath,
        uid: '',
      );
      userBox.add(newUser);
      setState(() {
        userImage = imagePath;
      });
    }
  }

  void saveUserName(String name) {
    final userBox = Boxes.getUser();
    if (userBox.isNotEmpty) {
      final user = userBox.getAt(0);
      final updatedUser = UserModel(
        name: name,
        image: user!.image,
        uid: user.uid,
      );
      userBox.putAt(0, updatedUser);
    } else {
      final newUser = UserModel(
        name: name,
        image: userImage,
        uid: '',
      );
      userBox.add(newUser);
    }
    setState(() {
      userName = name;
      _isEditingName = false;
    });
  }

  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBox = Boxes.getUser();
      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        setState(() {
          userName = user!.name.isNotEmpty ? user.name : 'Guest';
          userImage = user.image;
          _nameController.text = userName;
        });
      } else {
        _nameController.text = userName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2A2A2A),
                    const Color(0xFF0A0A0A),
                  ]
                : [
                    const Color(0xFFF8F8F8),
                    const Color(0xFFE8E8E8),
                    const Color(0xFFD8D8D8),
                    const Color(0xFFF0F0F0),
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color.fromRGBO(255, 255, 255, 0.1)
                              : const Color.fromRGBO(0, 0, 0, 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ).createShader(bounds),
                            child: Text(
                              'Profile',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: BuildDisplayImage(
                          file: file,
                          userImage: userImage,
                          onPressed: pickImage,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _isEditingName
                          ? Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: TextField(
                                controller: _nameController,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? const Color.fromRGBO(
                                              255, 255, 255, 0.2)
                                          : const Color.fromRGBO(
                                              174, 128, 72, 0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: primaryColor),
                                        onPressed: () {
                                          if (_nameController.text
                                              .trim()
                                              .isNotEmpty) {
                                            saveUserName(
                                                _nameController.text.trim());
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54),
                                        onPressed: () {
                                          setState(() {
                                            _nameController.text = userName;
                                            _isEditingName = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditingName = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: isDark
                                          ? [
                                              Colors.white,
                                              const Color(0xFFC0C0C0)
                                            ]
                                          : [primaryColor, secondaryColor],
                                    ).createShader(bounds),
                                    child: Text(
                                      userName,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color.fromRGBO(
                                              255, 255, 255, 0.1)
                                          : const Color.fromRGBO(
                                              174, 128, 72, 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 40.0),
                      ValueListenableBuilder<Box<Settings>>(
                        valueListenable: Boxes.getSettings().listenable(),
                        builder: (context, box, child) {
                          if (box.isEmpty) {
                            return Column(
                              children: [
                                SettingsTile(
                                  icon: CupertinoIcons.mic,
                                  title: 'Enable AI voice',
                                  value: false,
                                  onChanged: (value) {
                                    final settingProvider =
                                        context.read<SettingsProvider>();
                                    settingProvider.toggleSpeak(value: value);
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                SettingsTile(
                                  icon: CupertinoIcons.sun_max,
                                  title: 'Theme',
                                  value: false,
                                  onChanged: (value) {
                                    final settingProvider =
                                        context.read<SettingsProvider>();
                                    settingProvider.toggleDarkMode(value: value);
                                  },
                                ),
                              ],
                            );
                          } else {
                            final settings = box.getAt(0);
                            return Column(
                              children: [
                                SettingsTile(
                                  icon: CupertinoIcons.mic,
                                  title: 'Enable AI voice',
                                  value: settings!.shouldSpeak,
                                  onChanged: (value) {
                                    final settingProvider =
                                        context.read<SettingsProvider>();
                                    settingProvider.toggleSpeak(
                                      value: value,
                                      settings: settings,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                SettingsTile(
                                  icon: settings.isDarkTheme
                                      ? CupertinoIcons.moon_fill
                                      : CupertinoIcons.sun_max_fill,
                                  title: 'Theme',
                                  value: settings.isDarkTheme,
                                  onChanged: (value) {
                                    final settingProvider =
                                        context.read<SettingsProvider>();
                                    settingProvider.toggleDarkMode(
                                      value: value,
                                      settings: settings,
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
