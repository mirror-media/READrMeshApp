# readr app
A new Flutter app about [READr](https://www.readr.tw/).

## Running cli

### debug mode
- flutter run --flavor dev lib/main_dev.dart
- flutter run --flavor staging lib/main_staging.dart
- flutter run --flavor prod lib/main_prod.dart

### release mode
- flutter run --flavor dev --release lib/main_dev.dart
- flutter run --flavor staging --release lib/main_staging.dart
- flutter run --flavor prod --release lib/main_prod.dart
 
### generate dev release archive
 - flutter build appbundle --flavor dev lib/main_dev.dart
 - flutter build ios --flavor dev lib/main_dev.dart

### generate staging release archive
 - flutter build appbundle --flavor staging lib/main_staging.dart
 - flutter build ios --flavor staging lib/main_staging.dart

### generate prod release archive
 - flutter build appbundle --obfuscate --split-debug-info=debug-info --flavor prod lib/main_prod.dart
 - flutter build ios --obfuscate --split-debug-info=debug-info --flavor prod lib/main_prod.dart
