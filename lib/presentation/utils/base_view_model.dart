import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_state.dart';

abstract class BaseViewModel<T extends Object> extends AsyncNotifier<BaseState<T>> {
  @override
  FutureOr<BaseState<T>> build() async => const BaseState.initial();
}