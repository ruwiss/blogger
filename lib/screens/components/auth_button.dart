import 'dart:async';

import 'package:blogmanname/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatefulWidget {
  final Function() onTap;
  final bool createBlog;
  const AuthButton({super.key, required this.onTap, required this.createBlog});

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _ripple = false;

  void _periodicAnimation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _ripple = false;
        timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _ripple = true),
      onTapUp: (_) => _periodicAnimation(),
      onTapCancel: () => _periodicAnimation(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: EdgeInsets.only(bottom: _ripple ? 5 : 0),
        padding: EdgeInsets.symmetric(
            vertical: _ripple ? 13 : 15, horizontal: _ripple ? 22 : 25),
        decoration: BoxDecoration(
            color: _ripple ? KColors.bloggerColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KColors.darkTeal, width: 0.6)),
        child: Text(
          widget.createBlog
              ? "Create a Blog"
              : _ripple
                  ? "PLEASE WAIT"
                  : "SIGN IN WITH GOOGLE",
          style: GoogleFonts.lexend(
              fontWeight: FontWeight.w500,
              color: _ripple ? Colors.white : null),
        ),
      ),
    );
  }
}
