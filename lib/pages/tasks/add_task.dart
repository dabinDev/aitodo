import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/add_task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

import 'bloc/task_bloc.dart';

/// @author panglu
/// @description 添加任务界面类
class AddTaskScreen extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  /// 构建添加任务界面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "添加任务",
          key: ValueKey(AddTaskKeys.ADD_TASK_TITLE),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: ValueKey(AddTaskKeys.ADD_TITLE),
                  validator: (value) {
                    var msg = value!.isEmpty ? "标题不能为空" : null;
                    return msg;
                  },
                  onSaved: (value) {
                    createTaskBloc.updateTitle = value!;
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(hintText: "标题")),
            ),
            key: _formState,
          ),
          ListTile(
            key: ValueKey("addProject"),
            leading: Icon(Icons.book),
            title: Text("项目"),
            subtitle: StreamBuilder<Project>(
              stream: createTaskBloc.selectedProject,
              initialData: Project.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data!.name),
            ),
            onTap: () {
              _showProjectsDialog(createTaskBloc, context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("截止日期"),
            subtitle: StreamBuilder<int>(
              stream: createTaskBloc.dueDateSelected,
              initialData: DateTime.now().millisecondsSinceEpoch,
              builder: (context, snapshot) =>
                  Text(getFormattedDate(snapshot.data!)),
            ),
            onTap: () {
              _selectDate(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text("优先级"),
            subtitle: StreamBuilder<Status>(
              stream: createTaskBloc.prioritySelected,
              initialData: Status.PRIORITY_4,
              builder: (context, snapshot) =>
                  Text(priorityText[snapshot.data!.index]),
            ),
            onTap: () {
              _showPriorityDialog(createTaskBloc, context);
            },
          ),
          ListTile(
              leading: Icon(Icons.label),
              title: Text("标签"),
              subtitle: StreamBuilder<String>(
                stream: createTaskBloc.labelSelection,
                initialData: "无标签",
                builder: (context, snapshot) => Text(snapshot.data!),
              ),
              onTap: () {
                _showLabelsDialog(context);
              }),
          ListTile(
            leading: Icon(Icons.mode_comment),
            title: Text("备注"),
            subtitle: Text("无备注"),
            onTap: () {
              showSnackbar(context, "即将推出");
            },
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text("提醒"),
            subtitle: Text("无提醒"),
            onTap: () {
              showSnackbar(context, "即将推出");
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddTaskKeys.ADD_TASK),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              createTaskBloc.createTask().listen((value) {
                if (context.isWiderScreen()) {
                  context.bloc<HomeBloc>().applyFilter("今天", Filter.byToday());
                } else {
                  context.safePop();
                }
              });
            }
          }),
    );
  }

  /// 选择日期对话框
  /// @param context 上下文
  Future<Null> _selectDate(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      createTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }

  /// 显示优先级选择对话框
  /// @param createTaskBloc 任务创建bloc
  /// @param context 上下文
  Future<Status?> _showPriorityDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return await showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: const Text('选择优先级'),
            children: <Widget>[
              buildContainer(context, Status.PRIORITY_1),
              buildContainer(context, Status.PRIORITY_2),
              buildContainer(context, Status.PRIORITY_3),
              buildContainer(context, Status.PRIORITY_4),
            ],
          );
        });
  }

  /// 显示项目选择对话框
  /// @param createTaskBloc 任务创建bloc
  /// @param context 上下文
  Future<Status?> _showProjectsDialog(
      AddTaskBloc createTaskBloc, BuildContext context) async {
    return showDialog<Status>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<List<Project>>(
              stream: createTaskBloc.projects,
              initialData: <Project>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('选择项目'),
                  children:
                      buildProjects(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  /// 显示标签选择对话框
  /// @param context 上下文
  Future<Status?> _showLabelsDialog(BuildContext context) async {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<Label>>(
              stream: createTaskBloc.labels,
              initialData: <Label>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('选择标签'),
                  children:
                      buildLabels(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  /// 构建项目列表
  /// @param createTaskBloc 任务创建bloc
  /// @param context 上下文
  /// @param projectList 项目列表
  List<Widget> buildProjects(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Project> projectList,
  ) {
    List<Widget> projects = [];
    projectList.forEach((project) {
      projects.add(ListTile(
        leading: Container(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(project.colorValue),
          ),
        ),
        title: Text(project.name),
        onTap: () {
          createTaskBloc.projectSelected(project);
          Navigator.pop(context);
        },
      ));
    });
    return projects;
  }

  /// 构建标签列表
  /// @param createTaskBloc 任务创建bloc
  /// @param context 上下文
  /// @param labelList 标签列表
  List<Widget> buildLabels(
    AddTaskBloc createTaskBloc,
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = [];
    labelList.forEach((label) {
      labels.add(ListTile(
        leading: Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
        title: Text(label.name),
        trailing: createTaskBloc.selectedLabels.contains(label)
            ? Icon(Icons.close)
            : Container(width: 18.0, height: 18.0),
        onTap: () {
          createTaskBloc.labelAddOrRemove(label);
          Navigator.pop(context);
        },
      ));
    });
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, Status status) {
    AddTaskBloc createTaskBloc = BlocProvider.of(context);
    return GestureDetector(
        onTap: () {
          createTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == createTaskBloc.lastPrioritySelection
                ? Colors.grey
                : Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 6.0,
                    color: priorityColor[status.index],
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(priorityText[status.index],
                    style: TextStyle(fontSize: 18.0)),
              ),
            )));
  }
}

class AddTaskProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: AddTaskBloc(TaskDB.get(), ProjectDB.get(), LabelDB.get()),
      child: AddTaskScreen(),
    );
  }
}
