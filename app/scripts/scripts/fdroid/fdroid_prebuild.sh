#!/bin/bash

sed -i -e '/in_app_purchase/d' pubspec.yaml
sed -i -e '/in_app_purchase/,/version:/d' pubspec.lock
sed -i -z -E -e 's/\n( +)if \(EnvVar\.enableInAppPurchase\) \{(\n(\1 +[^\n]*|\1|))*\n\1\}//' \
    -e 's/\n( +)if \(EnvVar\.enableInAppPurchase\)\n\1 +[A-Z][a-zA-Z]*\((\n(\1 +[^\n]*|\1|))*\n\1 +\),//' \
    -e 's/\nimport [^\n]*iap[^\n]*//g' lib/page/home_page/settings_page.dart lib/page/home_page.dart \
    lib/service/book.dart lib/page/settings_page/sync.dart
