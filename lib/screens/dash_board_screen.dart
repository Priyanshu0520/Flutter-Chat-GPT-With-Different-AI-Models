import 'dart:io';
import 'dart:ui';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/screens/chat_history_screen.dart';
import 'package:chatbotapp/screens/chat_screen.dart';
import 'package:chatbotapp/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _userImage = '';
  String _userName = 'Guest';
  String _selectedModel = 'nvidia/nemotron-3-nano-30b-a3b:free';

  static const Color primaryColor = Color.fromARGB(255, 174, 128, 72);
  static const Color secondaryColor = Color.fromARGB(255, 168, 93, 58);
  static const Color accentColor = Color.fromARGB(255, 198, 153, 99);

  void _loadUserData() {
    final userBox = Boxes.getUser();
    if (userBox.isNotEmpty) {
      final user = userBox.getAt(0);
      setState(() {
        _userName = user!.name.isNotEmpty ? user.name : 'Guest';
        _userImage = user.image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2A2A2A),
                    const Color(0xFF0A0A0A)
                  ]
                : [
                    const Color(0xFFF8F8F8),
                    const Color(0xFFE8E8E8),
                    const Color(0xFFD8D8D8),
                    const Color(0xFFF0F0F0)
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildGlassBar(context, isDark),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                                  colors: isDark
                                      ? [Colors.white, const Color(0xFFC0C0C0)]
                                      : [primaryColor, secondaryColor])
                              .createShader(bounds),
                          child: Text('👋 Hello, $_userName!',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2)),
                        ),
                        const SizedBox(height: 12),
                        Text('What can I help you with today?',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color.fromRGBO(255, 255, 255, 0.6)
                                    : const Color.fromRGBO(0, 0, 0, 0.5))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildGlassFeatureCard(
                            context: context,
                            title: 'Chat History',
                            subtitle: 'Browse conversations',
                            icon: Icons.history_rounded,
                            delay: 200,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatHistoryScreen()))),
                        const SizedBox(height: 20),
                        _buildGlassFeatureCard(
                            context: context,
                            title: 'New Chat',
                            subtitle: 'Start fresh conversation',
                            icon: Icons.auto_awesome_rounded,
                            delay: 400,
                            isDark: isDark,
                            isLarge: true,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatScreen()))),
                        const SizedBox(height: 30),
                        _buildQuickActionsSection(context, isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isDark
                      ? [secondaryColor, accentColor]
                      : [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: isDark
                        ? const Color.fromRGBO(0, 0, 0, 0.4)
                        : const Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('AI Assistant',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileScreen()),
              );
              _loadUserData();
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: isDark
                        ? [secondaryColor, accentColor]
                        : [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(
                      color: isDark
                          ? const Color.fromRGBO(0, 0, 0, 0.4)
                          : const Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                backgroundImage: _userImage.isNotEmpty
                    ? FileImage(File(_userImage))
                    : const AssetImage('assets/images/profile_pic.jpeg')
                        as ImageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassFeatureCard(
      {required BuildContext context,
      required String title,
      required String subtitle,
      required IconData icon,
      required int delay,
      required bool isDark,
      required VoidCallback onTap,
      bool isLarge = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child)),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: isLarge ? 170 : 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color.fromRGBO(255, 255, 255, 0.08),
                            const Color.fromRGBO(255, 255, 255, 0.04),
                          ]
                        : [
                            const Color.fromRGBO(255, 255, 255, 0.8),
                            const Color.fromRGBO(255, 255, 255, 0.6),
                          ]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.15)
                        : const Color.fromRGBO(0, 0, 0, 0.08),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: isDark
                          ? const Color.fromRGBO(0, 0, 0, 0.3)
                          : const Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: isDark
                                    ? [secondaryColor, accentColor]
                                    : [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: isDark
                                      ? const Color.fromRGBO(0, 0, 0, 0.4)
                                      : const Color.fromRGBO(0, 0, 0, 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Icon(icon,
                              color: Colors.white, size: isLarge ? 28 : 24),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: isDark
                                  ? const Color.fromRGBO(255, 255, 255, 0.1)
                                  : const Color.fromRGBO(0, 0, 0, 0.05),
                              shape: BoxShape.circle),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 20),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: isLarge ? 26 : 22,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color.fromRGBO(255, 255, 255, 0.6)
                                    : const Color.fromRGBO(0, 0, 0, 0.5))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Model',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showModelSelectionBottomSheet(context, isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color.fromRGBO(255, 255, 255, 0.08),
                              const Color.fromRGBO(255, 255, 255, 0.04),
                            ]
                          : [
                              const Color.fromRGBO(255, 255, 255, 0.8),
                              const Color.fromRGBO(255, 255, 255, 0.6),
                            ]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.15)
                          : const Color.fromRGBO(0, 0, 0, 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: isDark
                                  ? [secondaryColor, accentColor]
                                  : [primaryColor, secondaryColor]),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.rocket_launch_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Model',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color.fromRGBO(255, 255, 255, 0.6)
                                      : const Color.fromRGBO(0, 0, 0, 0.5))),
                          const SizedBox(height: 4),
                          Text(
                              _selectedModel.split('/').last.split(':').first,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: isDark
                            ? const Color.fromRGBO(255, 255, 255, 0.6)
                            : const Color.fromRGBO(0, 0, 0, 0.5),
                        size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showModelSelectionBottomSheet(BuildContext context, bool isDark) {
    final models = [
      'tngtech/deepseek-r1t2-chimera:free',
      'nvidia/nemotron-3-nano-30b-a3b:free',
      'google/gemma-3-27b-it:free',
      'google/gemini-2.0-flash-exp:free',
      'mistralai/mistral-small-3.1-24b-instruct:free',
      'google/gemma-3-12b-it:free',
      'qwen/qwen-2.5-vl-7b-instruct:free',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color.fromRGBO(20, 20, 20, 0.95),
                        const Color.fromRGBO(10, 10, 10, 0.98),
                      ]
                    : [
                        const Color.fromRGBO(255, 255, 255, 0.95),
                        const Color.fromRGBO(245, 245, 245, 0.98),
                      ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                  color: isDark
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(0, 0, 0, 0.1)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.3)
                        : const Color.fromRGBO(0, 0, 0, 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [primaryColor, secondaryColor]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text('Select AI Model',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    final isSelected = model == _selectedModel;
                    final modelName = model.split('/').last.split(':').first;
                    final provider = model.split('/').first;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedModel = model;
                          });
                          context
                              .read<ChatProvider>()
                              .setCurrentModel(newModel: model);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [primaryColor, secondaryColor])
                                : LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color.fromRGBO(
                                                255, 255, 255, 0.05),
                                            const Color.fromRGBO(
                                                255, 255, 255, 0.02),
                                          ]
                                        : [
                                            const Color.fromRGBO(
                                                255, 255, 255, 0.8),
                                            const Color.fromRGBO(
                                                255, 255, 255, 0.6),
                                          ]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : isDark
                                        ? const Color.fromRGBO(
                                            255, 255, 255, 0.1)
                                        : const Color.fromRGBO(0, 0, 0, 0.1),
                                width: isSelected ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : isDark
                                          ? const Color.fromRGBO(
                                              255, 255, 255, 0.1)
                                          : const Color.fromRGBO(0, 0, 0, 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: isSelected
                                      ? Colors.white
                                      : isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(modelName,
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : isDark
                                                    ? Colors.white
                                                    : Colors.black87)),
                                    const SizedBox(height: 2),
                                    Text(provider,
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : isDark
                                                    ? const Color.fromRGBO(
                                                        255, 255, 255, 0.6)
                                                    : const Color.fromRGBO(
                                                        0, 0, 0, 0.5))),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
