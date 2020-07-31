// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/dart/abstract_producer.dart';
import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class RemoveThisExpression extends CorrectionProducer {
  @override
  FixKind get fixKind => DartFixKind.REMOVE_THIS_EXPRESSION;

  @override
  Future<void> compute(DartChangeBuilder builder) async {
    var node = this.node;
    if (node is ConstructorFieldInitializer) {
      var thisKeyword = node.thisKeyword;
      if (thisKeyword != null) {
        await builder.addFileEdit(file, (DartFileEditBuilder builder) {
          var fieldName = node.fieldName;
          builder.addDeletion(range.startStart(thisKeyword, fieldName));
        });
      }
      return;
    } else if (node is PropertyAccess && node.target is ThisExpression) {
      await builder.addFileEdit(file, (DartFileEditBuilder builder) {
        builder.addDeletion(range.startEnd(node, node.operator));
      });
    } else if (node is MethodInvocation && node.target is ThisExpression) {
      await builder.addFileEdit(file, (DartFileEditBuilder builder) {
        builder.addDeletion(range.startEnd(node, node.operator));
      });
    }
  }

  /// Return an instance of this class. Used as a tear-off in `FixProcessor`.
  static RemoveThisExpression newInstance() => RemoveThisExpression();
}
