import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';

/// @author panglu
/// @description 任务列表页面类
class TasksPage extends StatelessWidget {
  /// 构建任务列表页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    final TaskBloc _taskBloc = BlocProvider.of<TaskBloc>(context);
    return StreamBuilder<List<Tasks>>(
      stream: _taskBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data!, _taskBloc);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  /// 构建任务列表
  /// @param list 任务列表
  /// @param taskBloc 任务bloc
  /// @return 任务列表组件
  Widget _buildTaskList(List<Tasks> list, TaskBloc taskBloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget("无任务")
          : Container(
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRect(
                      child: Dismissible(
                          key: ValueKey("swipe_${list[index].id}_$index"),
                          onDismissed: (DismissDirection direction) {
                            var taskID = list[index].id!;
                            final TaskBloc _tasksBloc =
                                BlocProvider.of<TaskBloc>(context);
                            String message = "";
                            if (direction == DismissDirection.endToStart) {
                              _tasksBloc.updateStatus(
                                  taskID, TaskStatus.COMPLETE);
                              message = "任务已完成";
                            } else {
                              _tasksBloc.delete(taskID);
                              message = "任务已删除";
                            }
                            SnackBar snackbar =
                                SnackBar(content: Text(message));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);
                          },
                          background: Container(
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment(-0.95, 0.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.green,
                            child: Align(
                              alignment: Alignment(0.95, 0.0),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                          child: TaskRow(list[index])),
                    );
                  }),
            ),
    );
  }
}
