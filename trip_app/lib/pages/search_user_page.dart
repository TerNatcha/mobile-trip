import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchUserPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const SearchUserPage({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  String searchQuery = '';
  List<dynamic> searchResults = [];
  bool isLoading = false;
  int currentPage = 1;
  bool hasMore = true;

  final PageController _pageController = PageController();

  Future<void> _searchUsernames(String query, {int page = 1}) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        hasMore = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(
          'https://yasupada.com/mobiletrip/api.php?action=search_users&query=$query&page=$page'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            if (page == 1) {
              searchResults = data['data'];
            } else {
              searchResults.addAll(data['data']);
            }
            hasMore = data['data'].length > 0;
          });
        } else {
          setState(() {
            hasMore = false;
          });
        }
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _inviteUserToGroup(String userId) {
    // Logic to invite user to group
    print('Inviting user with ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                currentPage = 1;
                _searchUsernames(searchQuery, page: currentPage);
              },
              decoration: InputDecoration(
                hintText: 'Enter username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  if (hasMore && page == currentPage - 1) {
                    currentPage++;
                    _searchUsernames(searchQuery, page: currentPage);
                  }
                },
                itemCount: (searchResults.length / 10).ceil(),
                itemBuilder: (context, pageIndex) {
                  final pageResults =
                      searchResults.skip(pageIndex * 10).take(10).toList();

                  return ListView.separated(
                    itemCount: pageResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = pageResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user['username'][0].toUpperCase()),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: Icon(Icons.person_add,
                            color: Theme.of(context).primaryColor),
                        onTap: () {
                          _inviteUserToGroup(user['id']);
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
