import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflectionNotes extends StatelessWidget {
  const ReflectionNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
      child: const Center(child: Text('Reflection Notes')),
    );
  }
}
