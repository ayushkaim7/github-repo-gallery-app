import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Gitrepo extends StatefulWidget {
  const Gitrepo({super.key});

  @override
  State<Gitrepo> createState() => _GitrepoState();
}

class _GitrepoState extends State<Gitrepo> {
  List gists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGists();
  }

  Future<void> fetchGists() async {
    final response =
        await http.get(Uri.parse('https://api.github.com/gists/public'));
    if (response.statusCode == 200) {
      setState(() {
        gists = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load gists');
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Gists'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: gists.length,
              itemBuilder: (context, index) {
                final gist = gists[index];
                final owner = gist['owner'] ?? {};
                return GestureDetector(
                  onTap: () async {
                    final url = gist['html_url'];
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(owner['avatar_url'] ?? ''),
                                radius: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      owner['login'] ?? 'Unknown User',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Comments: ${gist['comments'] ?? 0}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.link),
                                color: Colors.blueAccent,
                                onPressed: () async {
                                  final url = gist['html_url'];
                                  if (url != null) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    print("URL is null, cannot launch");
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            gist['description'] ?? 'No description available',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey),
                                      SizedBox(width: 5),
                                      Text(
                                        'Created: ${formatDate(gist['created_at'])}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.update,
                                          size: 14, color: Colors.grey),
                                      SizedBox(width: 5),
                                      Text(
                                        'Updated: ${formatDate(gist['updated_at'])}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
