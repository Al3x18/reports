import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/delegates/my_silver_app_bar_delegate.dart';
import 'package:reports/view/widgets/general_loading.dart';
import 'package:reports/view/manage_user_view.dart';

class UsersListView extends ConsumerWidget {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream =
        FirebaseFirestore.instance.collection('users').snapshots();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    void goToUserDetailsScreen(Map<String, dynamic> userDetails) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManageUserView(userDetails: userDetails),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GeneralLoadingScreen();
          }

          final data = snapshot.data;
          if (!snapshot.hasData || data == null || data.docs.isEmpty) {
            return const Center(child: Text('No Data Found.'));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final usersSnapshot = data.docs;
          final usersList = usersSnapshot.map((e) => e.data()).toList();

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: MySliverAppBarDelegate(
                  child: Center(
                    child: Text(
                      '[Number of currently Registered Users: ${usersList.length}]',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                floating: false,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return InkWell(
                      onTap: () =>
                          goToUserDetailsScreen(usersList[index]),
                      child: ListTile(
                        title: Text(usersList[index]['name'] as String? ?? ''),
                        subtitle:
                            Text(usersList[index]['email'] as String? ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentUserUid == usersList[index]['uid'])
                              const Text("It's you!"),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_ios, size: 19),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: usersSnapshot.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
