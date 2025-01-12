import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_bloc.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';

/// @author panglu
/// @description 添加标签页面类
class AddLabel extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  /// 构建添加标签页面
  /// @param context 构建上下文
  @override
  Widget build(BuildContext context) {
    late ColorPalette currentSelectedPalette;
    LabelBloc labelBloc = BlocProvider.of(context);
    String labelName = "";
    scheduleMicrotask(() {
      labelBloc.labelsExist.listen((isExist) {
        if (isExist) {
          showSnackbar(context, "标签已存在");
        } else {
          context.safePop();
          if (context.isWiderScreen()) {
            context.bloc<HomeBloc>().updateScreen(SCREEN.HOME);
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "添加标签",
          key: ValueKey(AddLabelKeys.TITLE_ADD_LABEL),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddLabelKeys.ADD_LABEL_BUTTON),
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () async {
            if (_formState.currentState?.validate() ?? false) {
              _formState.currentState?.save();
              var label = Label.create(
                  labelName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName);
              labelBloc.checkIfLabelExist(label);
            }
          }),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME),
                decoration: InputDecoration(hintText: "标签名称"),
                maxLength: 20,
                validator: (value) {
                  return value!.isEmpty ? "标签名称不能为空" : null;
                },
                onSaved: (value) {
                  labelName = value!;
                },
              ),
            ),
            key: _formState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: StreamBuilder<ColorPalette>(
              stream: labelBloc.colorSelection,
              initialData: ColorPalette("灰色", Colors.grey.value),
              builder: (context, snapshot) {
                currentSelectedPalette = snapshot.data!;
                return CollapsibleExpansionTile(
                  key: expansionTile,
                  leading: Icon(
                    Icons.label,
                    size: 16.0,
                    color: Color(currentSelectedPalette.colorValue),
                  ),
                  title: Text(currentSelectedPalette.colorName),
                  children: buildMaterialColors(labelBloc),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// 构建颜色选择列表
  /// @param labelBloc 标签bloc
  /// @return 颜色选择列表组件
  List<Widget> buildMaterialColors(LabelBloc labelBloc) {
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          labelBloc.updateColorSelection(
            ColorPalette(colors.colorName, colors.colorValue),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}
