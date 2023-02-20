import 'package:blogmanname/constants/colors.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/screens/components/auth_button.dart';
import 'package:blogmanname/screens/components/auth_clippath.dart';
import 'package:blogmanname/services/auth_service.dart';
import 'package:blogmanname/services/blogger_service.dart';
import 'package:blogmanname/services/local_service.dart';
import 'package:blogmanname/services/other_services.dart';
import 'package:blogmanname/viewmodels/auth_v_model.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool? _isLogged;
  bool _showCreateBlogBtn = false;

  void _checkIsLogged() async {
    _isLogged = await locator.get<LocalService>().isLogged();
    if (!_isLogged!) {
      changeStatusBarColor(KColors.teal);
    }
    setState(() {});
  }

  @override
  void initState() {
    _checkIsLogged();
    super.initState();
  }

  void _authUser(BuildContext context) {
    final blogViewModel = Provider.of<BlogViewModel>(context, listen: false);
    locator.get<AuthService>().authWithGoogle(
        whenGotBlogs: (blogsJson) => blogViewModel.setUserBlogs(blogsJson),
        onLogin: (user, accessToken) {
          final authViewModel =
              Provider.of<AuthViewModel>(context, listen: false);
          authViewModel.setUser(user!);
          if (blogViewModel.userBlogs!.items == null) {
            locator.get<AuthService>().signOut();
            setState(() {
              _showCreateBlogBtn = true;
            });
          } else {
            locator.get<LocalService>().whenSignIn();
            final firstBlog = blogViewModel.userBlogs!.items!.first;
            blogViewModel.setSelectedBlog({
              "id": firstBlog.id,
              "url": firstBlog.url,
              "title": firstBlog.name
            });
            locator.get<BloggerService>().fetchPostsOrPages(
                context, blogViewModel.userBlogs!.items!.first.posts!.selfLink);
            Navigator.pushReplacementNamed(context, "/home");
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (_isLogged != null && _isLogged == true) _authUser(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            _titleWidget(),
            const Expanded(child: SizedBox()),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _isLogged == false ? 1 : 0,
                  child: CustomPaint(
                    size: Size(width, 200),
                    painter: AuthClipPath(),
                  ),
                ),
                const Positioned(
                  bottom: 100,
                  width: 200,
                  height: 130,
                  child: RiveAnimation.asset(
                      "assets/animations/pencil_animation.riv"),
                ),
                Positioned(
                  bottom: _showCreateBlogBtn ? 0 : 58,
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _isLogged == false ? 1 : 0,
                    child: Column(
                      children: [
                        AuthButton(
                          createBlog: _showCreateBlogBtn,
                          onTap: (() => _showCreateBlogBtn
                              ? launchUrl(Uri.parse("https://www.blogger.com/"),
                                      mode: LaunchMode.externalApplication)
                                  .then((value) {
                                  setState(() => _showCreateBlogBtn = false);
                                })
                              : _authUser(context)),
                        ),
                        if (_showCreateBlogBtn)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text("You don't have a blog",
                                  style: GoogleFonts.poppins(
                                      fontSize: 17, color: Colors.white))),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleWidget() {
    const style = TextStyle(
        fontFamily: "Blogger", fontWeight: FontWeight.bold, fontSize: 50);
    return Column(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CircleAvatar(
                radius: 45,
                child: Image.asset("assets/images/bloggerman.png"))),
        const SizedBox(height: 40),
        Text.rich(
          TextSpan(
              text: "Blogger",
              style: style.copyWith(color: KColors.teal),
              children: [
                TextSpan(
                  text: "man",
                  style: style.copyWith(color: KColors.bloggerColor),
                )
              ]),
        ),
      ],
    );
  }
}
