import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label_bloc.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project_bloc.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

/// @author panglu
/// @description 侧边栏组件类
class SideDrawer extends StatelessWidget {
  /// 构建侧边栏界面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("panglu"),
            accountEmail: Text("panglu@gmail.com"),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    await context.adaptiveNavigate(
                        SCREEN.ABOUT, AboutUsScreen());
                  })
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: AssetImage("assets/profile_pic.jpg"),
            ),
          ),
          ListTile(
              leading: Icon(Icons.inbox),
              title: Text(
                "收件箱",
                key: ValueKey(SideDrawerKeys.INBOX),
              ),
              onTap: () {
                var project = Project.getInbox();
                homeBloc.applyFilter(
                    project.name, Filter.byProject(project.id!));
                context.safePop();
              }),
          ListTile(
              onTap: () {
                homeBloc.applyFilter("今天", Filter.byToday());
                context.safePop();
              },
              leading: Icon(Icons.calendar_today),
              title: Text(
                "今天",
                key: ValueKey(SideDrawerKeys.TODAY),
              )),
          ListTile(
            onTap: () {
              homeBloc.applyFilter("未来7天", Filter.byNextWeek());
              context.safePop();
            },
            leading: Icon(Icons.calendar_today),
            title: Text(
              "未来7天",
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          BlocProvider(
            bloc: ProjectBloc(ProjectDB.get()),
            child: ProjectPage(),
          ),
          BlocProvider(
            bloc: LabelBloc(LabelDB.get()),
            child: LabelPage(),
          )
        ],
      ),
    );
  }
}
