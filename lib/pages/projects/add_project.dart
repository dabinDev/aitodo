import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_bloc.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

/// @author panglu
/// @description 添加项目页面类
class AddProject extends StatelessWidget {
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  /// 构建添加项目页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    ProjectBloc _projectBloc = BlocProvider.of(context);
    late ColorPalette currentSelectedPalette;
    String projectName = "";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "添加项目",
          key: ValueKey(AddProjectKeys.TITLE_ADD_PROJECT),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON),
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              var project = Project.create(
                  projectName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName);
              _projectBloc.createProject(project);
              if (context.isWiderScreen()) {
                context.bloc<HomeBloc>().updateScreen(SCREEN.HOME);
              }
              context.safePop();
              _projectBloc.refresh();
            }
          }),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey(AddProjectKeys.TEXT_FORM_PROJECT_NAME),
                decoration: InputDecoration(hintText: "项目名称"),
                maxLength: 20,
                validator: (value) {
                  return value!.isEmpty ? "项目名称不能为空" : null;
                },
                onSaved: (value) {
                  projectName = value!;
                },
              ),
            ),
            key: _formState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: StreamBuilder<ColorPalette>(
              stream: _projectBloc.colorSelection,
              initialData: ColorPalette("灰色", Colors.grey.value),
              builder: (context, snapshot) {
                currentSelectedPalette = snapshot.data!;
                return CollapsibleExpansionTile(
                  key: expansionTile,
                  leading: Container(
                    width: 12.0,
                    height: 12.0,
                    child: CircleAvatar(
                      backgroundColor: Color(snapshot.data!.colorValue),
                    ),
                  ),
                  title: Text(snapshot.data!.colorName),
                  children: buildMaterialColors(_projectBloc),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// 构建颜色选择列表
  /// @param projectBloc 项目bloc
  /// @return 颜色选择列表组件
  List<Widget> buildMaterialColors(ProjectBloc projectBloc) {
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Container(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(colors.colorValue),
          ),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          projectBloc.updateColorSelection(
            ColorPalette(colors.colorName, colors.colorValue),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}
