import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List post = [];
  int page = 1;
  bool isLoadingMore = false;

  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(_scrollListner);
    fetchPost();
  }

  Future<void> _scrollListner() async {
    if (isLoadingMore) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      page = page + 1;

      setState(() {
        isLoadingMore = true;
      });

      await fetchPost();
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> fetchPost() async {
    final url =
        'https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=10&page=1';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;

      setState(() {
        post = post + json;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pegination Demo'),
      ),
      body: (post.isEmpty)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              controller: scrollController,
              itemCount: isLoadingMore ? post.length + 1 : post.length,
              itemBuilder: (context, index) {
                if (index < post.length) {
                  final postName = post[index];
                  final title = postName['title']['rendered'];
                  final description = postName['slug'];

                  return Card(
                    child: ListTile(
                      title: Text(
                        title.toString(),
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        description.toString(),
                        maxLines: 2,
                      ),
                      leading: CircleAvatar(
                        child: Text('${index + 1}'.toString()),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
    );
  }
}
