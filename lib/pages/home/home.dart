import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/home/side_drawer.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_completed/task_complted.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/task_widgets.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

/// @author AI Todo Team
/// @description 主页面类，显示任务列表和相关操作
class HomePage extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// 构建主页面界面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    final bool isWiderScreen = context.isWiderScreen();
    final homeBloc = context.bloc<HomeBloc>();
    scheduleMicrotask(() {
      StreamSubscription? _filterSubscription;
      _filterSubscription = homeBloc.filter.listen((filter) {
        _taskBloc.updateFilters(filter);
        //_filterSubscription?.cancel();
      });
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: StreamBuilder<String>(
            initialData: '今天',
            stream: homeBloc.title,
            builder: (context, snapshot) {
              return Text(
                snapshot.data!,
                key: ValueKey(HomePageKeys.HOME_TITLE),
              );
            }),
        actions: <Widget>[buildPopupMenu(context)],
        leading: isWiderScreen
            ? null
            : new IconButton(
                icon: new Icon(
                  Icons.menu,
                  key: ValueKey(SideDrawerKeys.DRAWER),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        key: ValueKey(HomePageKeys.ADD_NEW_TASK_BUTTON),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        onPressed: () async {
          await context.adaptiveNavigate(SCREEN.ADD_TASK, AddTaskProvider());
          _taskBloc.refresh();
        },
      ),
      drawer: isWiderScreen ? null : SideDrawer(),
      body: BlocProvider(
        bloc: _taskBloc,
        child: TasksPage(),
      ),
    );
  }

  /// 构建弹出菜单
  /// @param context 构建上下文
  /// @return 弹出菜单组件
  Widget buildPopupMenu(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      icon: Icon(Icons.adaptive.more),
      key: ValueKey(CompletedTaskPageKeys.POPUP_ACTION),
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.TASK_COMPLETED:
            await context.adaptiveNavigate(
                SCREEN.COMPLETED_TASK, TaskCompletedPage());
            _taskBloc.refresh();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
        const PopupMenuItem<MenuItem>(
          value: MenuItem.TASK_COMPLETED,
          child: const Text(
            '已完成任务',
            key: ValueKey(CompletedTaskPageKeys.COMPLETED_TASKS),
          ),
        )
      ],
    );
  }
}

/// 菜单项枚举
enum MenuItem { TASK_COMPLETED }
