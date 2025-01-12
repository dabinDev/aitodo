import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/projects/add_project.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_bloc.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

/// @author panglu
/// @description 项目页面类
class ProjectPage extends StatelessWidget {
  /// 构建项目页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    ProjectBloc projectBloc = BlocProvider.of<ProjectBloc>(context);
    return StreamBuilder<List<Project>>(
      stream: projectBloc.projects,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ProjectExpansionTileWidget(snapshot.data!);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

/// @author panglu
/// @description 项目展开列表组件类
class ProjectExpansionTileWidget extends StatelessWidget {
  final List<Project> _projects;

  ProjectExpansionTileWidget(this._projects);

  /// 构建项目展开列表
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(SideDrawerKeys.DRAWER_PROJECTS),
      leading: Icon(Icons.book),
      title: Text("项目列表",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildProjects(context),
    );
  }

  /// 构建项目列表
  /// @param context 构建上下文
  /// @return 项目列表组件
  List<Widget> buildProjects(BuildContext context) {
    List<Widget> projectWidgetList = [];
    _projects.forEach((project) => projectWidgetList.add(ProjectRow(project)));
    projectWidgetList.add(ListTile(
      key: ValueKey(SideDrawerKeys.ADD_PROJECT),
      leading: Icon(Icons.add),
      title: Text("添加项目"),
      onTap: () async {
        await context.adaptiveNavigate(SCREEN.ADD_PROJECT, AddProjectPage());
        context.bloc<ProjectBloc>().refresh();
      },
    ));
    return projectWidgetList;
  }
}

/// @author panglu
/// @description 项目行组件类
class ProjectRow extends StatelessWidget {
  final Project project;

  ProjectRow(this.project);

  /// 构建项目行
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of(context);
    return ListTile(
      key: ValueKey("tile_${project.name}_${project.id}"),
      onTap: () {
        homeBloc.applyFilter(project.name, Filter.byProject(project.id!));
        context.safePop();
      },
      leading: Container(
        key: ValueKey("space_${project.name}_${project.id}"),
        width: 24.0,
        height: 24.0,
      ),
      title: Text(
        project.name,
        key: ValueKey("${project.name}_${project.id}"),
      ),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: CircleAvatar(
          key: ValueKey("dot_${project.name}_${project.id}"),
          backgroundColor: Color(project.colorValue),
        ),
      ),
    );
  }
}

/// @author panglu
/// @description 添加项目页面包装类
class AddProjectPage extends StatelessWidget {
  /// 构建添加项目页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: ProjectBloc(ProjectDB.get()),
      child: AddProject(),
    );
  }
}
