import 'package:blogmanname/constants/colors.dart';
import 'package:blogmanname/extensions/datetime_extensions.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/models/views_model.dart';
import 'package:blogmanname/screens/components/user_profile.dart';
import 'package:blogmanname/services/blogger_service.dart';
import 'package:blogmanname/services/other_services.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    changeStatusBarColor(Colors.black);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Provider.of<BlogViewModel>(context).userBlogs == null
          ? TextButton(onPressed: () {}, child: const Text("Create a Blog"))
          : Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Consumer<BlogViewModel>(
                        builder: (context, value, child) {
                          return _blogSelectButton(value);
                        },
                      ),
                      UserProfileWidget(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _tabBarWidget(),
                  const SizedBox(height: 30),
                  Consumer<BlogViewModel>(
                    builder: (context, value, child) {
                      return Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: value.isLoading
                                      ? const SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                            color: KColors.bloggerColor,
                                          ))
                                      : value.userPosts == null ||
                                              value.userPosts!.items == null
                                          ? const Text(
                                              "start with create a post",
                                              textAlign: TextAlign.center)
                                          : _blogWidget(value)),
                            ),
                            if (value.blogViews.length == 3)
                              _blogViews(value.blogViews),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Consumer<BlogViewModel>(
        builder: (context, value, child) =>
            value.selectedBlog['id'] != null && _tabIndex != 2
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 45, right: 5),
                    child: FloatingActionButton.small(
                      onPressed: () =>
                          locator.get<BloggerService>().createEmptyDraft(
                        context,
                        value.selectedBlog['id']!,
                        isPage: _tabIndex == 1,
                        onCreate: (items) {
                          items.status = "DRAFT";
                          Navigator.pushNamed(context, "/content", arguments: {
                            "type": "draft",
                            "edit": false,
                            "content": items
                          });
                        },
                      ),
                      backgroundColor: Colors.teal.shade100,
                      child: value.isNewPostCreating
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator())
                          : const Icon(Icons.add),
                    ),
                  )
                : const SizedBox(),
      ),
    ));
  }

  Container _blogViews(List<ViewsModel> viewsList) {
    convertValueToK(String value) => int.parse(value) < 1000
        ? value.toString()
        : "${(int.parse(value) / 1000).toStringAsFixed(1)}K";

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: KColors.teal.withOpacity(.2),
          borderRadius: BorderRadius.circular(5)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: viewsList
              .map((e) => IntrinsicHeight(
                    child: Row(
                      children: [
                        Text(
                          "${e.range} ",
                          style: GoogleFonts.aBeeZee(color: Colors.black54),
                        ),
                        Text("${convertValueToK(e.count)} ",
                            style: GoogleFonts.aBeeZee()),
                        const Icon(Icons.remove_red_eye, size: 15),
                        if (viewsList.indexOf(e) != 2)
                          const VerticalDivider(color: Colors.white)
                      ],
                    ),
                  ))
              .toList()),
    );
  }

  Widget _tabBarWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(0, 1), blurRadius: 0.5)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tabItem(id: 0, text: "Posts"),
          _tabItem(id: 1, text: "Pages"),
          _tabItem(id: 2, text: "Drafts"),
        ],
      ),
    );
  }

  Widget _tabItem({required String text, required int id}) {
    return InkWell(
      onTap: () async {
        final blogViewModel =
            Provider.of<BlogViewModel>(context, listen: false);
        if (!blogViewModel.isLoading) {
          setState(() => _tabIndex = id);
          final blogService = locator.get<BloggerService>();
          blogViewModel.setIsLoading(true);
          await blogService.fetchPostsOrPages(context,
              "${blogService.selfUrl.replaceAll(blogService.selfUrl.split("/").last, "")}${text.toLowerCase()}",
              isDraft: text == "Drafts");
          blogViewModel.setIsLoading(false);
        }
      },
      child: Text(
        text,
        style: GoogleFonts.aBeeZee(
            color: id == _tabIndex ? KColors.bloggerColor : KColors.darkTeal,
            fontWeight: id == _tabIndex ? FontWeight.bold : FontWeight.w400,
            fontSize: 15),
      ),
    );
  }

  Widget _blogWidget(BlogViewModel value) {
    return Column(
        children: value.userPosts!.items!.map((e) {
      final dateTime = DateTime.parse(e.published);
      String? imageUrl;
      for (var type in [".png", ".jpeg", ".jpg", ".webp"]) {
        if (e.content.contains(type)) {
          imageUrl = "${e.content.split(type).first.split('"').last}$type";
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.pushNamed(context, "/content", arguments: {
              "type": e.status == "SCHEDULED"
                  ? "draft"
                  : _tabIndex == 0
                      ? "posts"
                      : _tabIndex == 1
                          ? "pages"
                          : "draft",
              "edit": _tabIndex != 2,
              "content": e
            });
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: KColors.teal.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 145,
                            child: Text(e.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(dateTime.formatDate(false),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black87)),
                              const SizedBox(width: 5),
                              if (_tabIndex != 2)
                                Container(
                                    child: int.parse(e.replies.totalItems) > 0
                                        ? TextButton(
                                            onPressed: () => Navigator.pushNamed(
                                                context, "/comments",
                                                arguments: e.replies.selfLink),
                                            child: Text(
                                                e.status ??
                                                    "Show ${e.replies.totalItems} Comments",
                                                style: GoogleFonts.aBeeZee(
                                                    fontSize: 12,
                                                    color: Colors.teal)))
                                        : Text(e.status ?? "${e.replies.totalItems} Comments",
                                            style: GoogleFonts.aBeeZee(
                                                fontSize: 12))),
                            ],
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () =>
                              shareUrlAction(title: e.title, url: e.url),
                          icon: const Icon(Icons.share_outlined))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }).toList());
  }

  Widget _blogSelectButton(BlogViewModel value) {
    return DropdownButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        items: value.userBlogs!.items!
            .map((e) => DropdownMenuItem(
                value: e.name,
                child: Text(
                  e.name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: KColors.darkTeal),
                )))
            .toList(),
        value: Provider.of<BlogViewModel>(context).selectedBlog['title'] ??
            value.userBlogs!.items!.first.name,
        underline: const SizedBox(),
        onChanged: (selection) async {
          setState(() => _tabIndex = 0);
          final item = value.userBlogs!.items!
              .singleWhere((element) => element.name == selection);
          final blogViewModel =
              Provider.of<BlogViewModel>(context, listen: false);
          final String selfLink = item.posts!.selfLink;
          blogViewModel.setSelectedBlog(
              {"id": item.id, "title": selection ?? "", "url": item.url});
          blogViewModel.setIsLoading(true);
          await locator
              .get<BloggerService>()
              .fetchPostsOrPages(context, selfLink);
          blogViewModel.setIsLoading(false);
        });
  }
}
