import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/wine.dart';

part 'wines_state.freezed.dart';

@freezed
class WinesState with _$WinesState {
  const factory WinesState.initial() = _Initial;
  const factory WinesState.loading() = _Loading;
  const factory WinesState.success(List<Wine> wines) = _Success;
  const factory WinesState.error(String message) = _Error;
}