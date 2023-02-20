import 'package:blogmanname/locator.dart';
import 'package:blogmanname/services/auth_service.dart';
import 'package:blogmanname/viewmodels/auth_v_model.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, value, child) => InkWell(
        onTap: () => _showModalBottomProfile(context),
        child: _profileImage(value.user.photoURL!, isSmall: true),
      ),
    );
  }

  Widget _profileImage(String url, {bool isSmall = true}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: CircleAvatar(
        radius: isSmall ? 18 : 25,
        child: Image.network(url),
      ),
    );
  }

  void _showModalBottomProfile(BuildContext context) {
    listTile(String title, IconData icon, Function onTap) => InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: ListTile(title: Text(title), leading: Icon(icon)));

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        barrierColor: Colors.black12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Consumer<AuthViewModel>(
              builder: (context, value, child) => Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 30),
                          child: _profileImage(value.user.photoURL!,
                              isSmall: false),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value.user.displayName!,
                                  style: GoogleFonts.poppins(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                value.user.email!,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        listTile("Show Blog", Icons.web_asset, () {
                          Navigator.pop(context);
                          launchUrl(
                              Uri.parse(Provider.of<BlogViewModel>(context,
                                      listen: false)
                                  .selectedBlog['url']!),
                              mode: LaunchMode.externalApplication);
                        }),
                        listTile("Vote App", Icons.star_border_rounded, () {
                          Navigator.pop(context);

                          launchUrl(
                              Uri.parse(
                                  "https://play.google.com/store/apps/details?id=com.rw.blogman"),
                              mode: LaunchMode.externalApplication);
                        }),
                        listTile("Sign Out", Icons.exit_to_app, () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/", (route) => false);
                          locator.get<AuthService>().signOut();
                        })
                      ],
                    )
                  ],
                ),
              ),
            ));
  }
}
