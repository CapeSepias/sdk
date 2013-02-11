// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library timer_cancel_test;

import 'dart:async';
import 'dart:isolate';
import '../../pkg/unittest/lib/unittest.dart';

main() {
  final ms = const Duration(milliseconds: 1);
  test("simple timer", () {
    Timer cancelTimer;
    int repeatTimer;

    void unreachable() {
      fail("should not be reached");
    }

    void handler() {
      cancelTimer.cancel();
    }

    void repeatHandler(Timer timer) {
      repeatTimer++;
      timer.cancel();
      expect(repeatTimer, 1);
    }

    cancelTimer = new Timer(ms * 1000, expectAsync0(unreachable, count: 0));
    cancelTimer.cancel();
    new Timer(ms * 1000, expectAsync0(handler));
    cancelTimer = new Timer(ms * 2000, expectAsync0(unreachable, count: 0));
    repeatTimer = 0;
    new Timer.repeating(ms * 1500, expectAsync1(repeatHandler));
  });
  
  test("cancel timer with same time", () {
    var t2;
    var t1 = Timer.run(expectAsync0(() => t2.cancel()));
    t2 = Timer.run(expectAsync0(t1.cancel, count: 0));
  });
}
