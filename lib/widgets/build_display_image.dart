import 'dart:io';
import 'package:flutter/material.dart';

class BuildDisplayImage extends StatelessWidget {
  const BuildDisplayImage({
    super.key,
    required this.file,
    required this.userImage,
    required this.onPressed,
  });

  final File? file;
  final String userImage;
  final VoidCallback onPressed;

  static const Color primaryColor = Color.fromARGB(255, 174, 128, 72);
  static const Color secondaryColor = Color.fromARGB(255, 168, 93, 58);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(174, 128, 72, 0.4),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.grey[200],
              backgroundImage: getImageToShow(),
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          right: 0.0,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(174, 128, 72, 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider getImageToShow() {
    if (file != null) {
      return FileImage(File(file!.path));
    } else if (userImage.isNotEmpty) {
      return FileImage(File(userImage));
    } else {
      return const NetworkImage(
          'https://i.pinimg.com/originals/0d/42/90/0d42905fc5e9d14fa032d8ea0282bf68.jpg');
    }
  }
}
