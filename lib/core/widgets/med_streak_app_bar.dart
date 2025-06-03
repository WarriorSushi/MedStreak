import 'package:flutter/material.dart';

/// A reusable app bar widget for MedStreak screens that includes a back button
/// The back button is shown by default and can be hidden with [showBackButton] parameter
class MedStreakAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool enableSound;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const MedStreakAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.enableSound = true,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                // Play sound effect if enabled
                if (enableSound) {
                  // TODO: Play button sound effect
                }
                
                // Use custom callback or default Navigator.pop
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
