import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;


  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
  
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(209, 233, 246, 1)
            ),
          ),
          Column(
            children: [
              if (appBar != null) appBar!,
              Expanded(child: body),
            ],
          ),
        ],
      ),
    );
  }
}
