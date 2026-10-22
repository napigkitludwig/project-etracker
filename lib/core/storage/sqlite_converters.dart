import 'package:json_annotation/json_annotation.dart';

/// Maps SQLite's `0` / `1` integers to a Dart [bool] (and back).
///
/// SQLite has no boolean type. Reading is tolerant — it also accepts real JSON
/// booleans and numeric strings — so the same model can parse rows *and* API
/// payloads.
class SqliteBoolConverter implements JsonConverter<bool, Object?> {
  const SqliteBoolConverter();

  @override
  bool fromJson(Object? json) {
    return switch (json) {
      bool value => value,
      num value => value != 0,
      String value => value == '1' || value.toLowerCase() == 'true',
      _ => false,
    };
  }

  @override
  Object? toJson(bool object) => object ? 1 : 0;
}
