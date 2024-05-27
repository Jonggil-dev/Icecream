import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/setting/provider/destination_provider.dart';
import 'package:kpostal/kpostal.dart';
import 'package:provider/provider.dart';

class KpostalWrapper extends StatelessWidget {
  final int user_id;

  const KpostalWrapper({Key? key, required this.user_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KpostalView(
      callback: (Kpostal result) {
        // 이곳에서 user_id와 result를 사용하여 필요한 작업을 수행
        Provider.of<Destination>(context, listen: false)
            .changeTheValue(result.address, result.latitude!, result.longitude!);
        // 추가적으로 userId를 사용하는 로직을 여기에 구현
        debugPrint("User ID: $user_id");
        context.pop();
      },
    );
  }
}