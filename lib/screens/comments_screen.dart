import 'package:blogmanname/constants/colors.dart';
import 'package:blogmanname/extensions/datetime_extensions.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/models/comments_model.dart' as commentsModel;
import 'package:blogmanname/services/blogger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentsScreen extends StatefulWidget {
  final String commentsLink;
  const CommentsScreen({super.key, required this.commentsLink});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<commentsModel.Items> _comments = [];

  @override
  void initState() {
    locator
        .get<BloggerService>()
        .getComments(widget.commentsLink)
        .then((value) {
      value
          .sort((a, b) => a.updated.toString().compareTo(b.updated.toString()));
      setState(() => _comments = value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Comments")),
      body: _comments.isEmpty
          ? const Center(
              child: SizedBox(
                  width: 30, height: 30, child: CircularProgressIndicator()))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final commentsModel.Items item = _comments[index];
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(item.author!.displayName!)),
                              Text(
                                DateTime.parse(item.updated).formatDate(true),
                                style: GoogleFonts.abel(
                                    fontSize: 12, color: Colors.black54),
                              )
                            ],
                          ),
                          Row(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: CircleAvatar(
                                  radius: 18,
                                  child: item.author == null
                                      ? Container(color: Colors.grey)
                                      : Image.network(item.author!.image!.url),
                                )),
                            const SizedBox(width: 10),
                            Flexible(
                                child: Html(
                              data: item.content,
                              onLinkTap: (url, c, a, e) => launchUrl(
                                  Uri.parse(url!),
                                  mode: LaunchMode.externalApplication),
                            )),
                          ]),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Are you sure?"),
                              content:
                                  const Text("The comment will be deleted"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("CANCEL")),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await locator
                                          .get<BloggerService>()
                                          .removeComment(item.selfLink);
                                      setState(() => _comments.removeAt(index));
                                    },
                                    child: const Text("DELETE"))
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.delete_forever_rounded,
                            color: Colors.red.shade300, size: 20)),
                  ],
                );
              },
            ),
    ));
  }
}
