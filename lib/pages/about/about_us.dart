import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_constant.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// @author panglu
/// @description 关于我们页面类
class AboutUsScreen extends StatelessWidget {
  /// 构建关于我们页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "关于我们",
          key: ValueKey(AboutUsKeys.TITLE_ABOUT),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.black),
                        title: Text(
                          "报告问题",
                          key: ValueKey(AboutUsKeys.TITLE_REPORT),
                        ),
                        subtitle: Text(
                          "遇到问题？在这里报告",
                          key: ValueKey(AboutUsKeys.SUBTITLE_REPORT),
                        ),
                        onTap: () => launchURL(ISSUE_URL)),
                    ListTile(
                      leading: Icon(Icons.update, color: Colors.black),
                      title: Text("版本"),
                      subtitle: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final versionName = snapshot.data?.version ?? '1.0.0';
                          return Text(
                            versionName,
                            key: ValueKey(AboutUsKeys.VERSION_NUMBER),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text("开发团队",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    ListTile(
                      leading: Icon(Icons.perm_identity, color: Colors.black),
                      title: Text(
                        "panglu",
                        key: ValueKey(AboutUsKeys.AUTHOR_NAME),
                      ),
                      subtitle: Text(
                        "aitodo",
                        key: ValueKey(AboutUsKeys.AUTHOR_USERNAME),
                      ),
                      onTap: () => launchURL(GITHUB_URL),
                    ),
                    ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.black),
                        title: Text("在 Github 上查看"),
                        onTap: () => launchURL(PROJECT_URL)),
                    ListTile(
                        leading: Icon(Icons.email, color: Colors.black),
                        title: Text("发送邮件"),
                        subtitle: Text(
                          "panglu@gmail.com",
                          key: ValueKey(AboutUsKeys.AUTHOR_EMAIL),
                        ),
                        onTap: () => launchURL(EMAIL_URL)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
