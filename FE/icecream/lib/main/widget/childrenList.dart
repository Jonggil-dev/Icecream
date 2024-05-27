import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/main/widget/expansion_tile_card.dart';

import '../../setting/widget/profile_image.dart';

class ChildList extends StatelessWidget {
  final Function(int childId, String childName, String? profileImage) onChildTap;
  const ChildList({super.key, required this.onChildTap});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final children = userProvider.children;
    final GlobalKey<ExpansionTileCardState> expansionTileKey = GlobalKey<ExpansionTileCardState>();

    print("자녀수: ${children.length}");

    return ExpansionTileCard(
      key: expansionTileKey,
      baseColor: Colors.amber[100],
      expandedColor: Colors.white,

      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("자녀 목록", style: TextStyle(fontSize: 16, fontFamily: 'GmarketSans')),
      ),
      contentPadding: EdgeInsets.zero,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(Icons.expand_more),
      ),
      children: <Widget>[
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: children.length + 1,
            itemBuilder: (context, index) {
              if (index == children.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 17.0),
                  child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2)
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 24, color: Colors.black),
                          onPressed: () {
                            context.pushNamed('qrscan_page');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                var child = children[index];
                final childImage = ProfileImage(isParent : false, width: 50, height: 50, user_id: child.userId, imgUrl: child.profileImage,);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: InkWell(
                    onTap: () {
                      expansionTileKey.currentState?.collapse();
                      onChildTap(child.userId, child.username, child.profileImage);
                    },
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 7),
                          childImage,
                          // Container(
                          //   width: 50,
                          //   height: 50,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(
                          //       color: Colors.greenAccent,
                          //       width: 2,
                          //     ),
                          //   ),
                          //   child: CircleAvatar(
                          //     radius: 25, // 아바타 반경
                          //     backgroundImage: profileimg,
                          //   ),
                          // ),
                          const SizedBox(height: 5),
                          Text(
                            child.username,
                            style: const TextStyle(fontSize: 12, fontFamily: 'GmarketSans'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
