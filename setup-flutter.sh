#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f "$0"))

FIREBASERC_PATH="${SCRIPT_DIR}/firebase/.firebaserc"
DART_DEFINES_PATH="${SCRIPT_DIR}/flutter/dart_defines"
FIREBASE_OPTIONS_TMP_PATH="${SCRIPT_DIR}/tmp"
FIREBASE_OPTIONS_DART_PATH="${SCRIPT_DIR}/flutter/lib/firebase_options.dart"

generate_dart_define() {
  ALIAS=$1
  NAME=$2
  
  read -p "Please enter the appIdSuffix for ${ALIAS} (e.g., .dev, leave empty if none): " APP_ID_SUFFIX

  JSON_DATA=$(cat <<- EOM
{
  "flavor": "$ALIAS",
  "appName": "$NAME$APP_ID_SUFFIX",
  "appIdSuffix": "$APP_ID_SUFFIX"
}
EOM
  )

  mkdir -p "$DART_DEFINES_PATH"
  echo "$JSON_DATA" > "$DART_DEFINES_PATH/$ALIAS.json"
}

declare -A FIREBASE_OPTIONS

generate_firebase_options() {
  ALIAS=$1
  FILENAME=$2

  local inside_block=false
  local current_platform=""
  local output_for_current_platform=""

  while IFS= read -r line
  do
    if [[ $line == *"static const FirebaseOptions "* ]]; then
      inside_block=true
      output_for_current_platform="FirebaseOptions(\n"

      # Identify platform
      if [[ $line == *"web"* ]]; then
        current_platform="web"
      elif [[ $line == *"ios"* ]]; then
        current_platform="ios"
      elif [[ $line == *"android"* ]]; then
        current_platform="android"
      fi

    elif [ "$inside_block" = true ]; then
      output_for_current_platform="${output_for_current_platform}${line}\n"
    fi

    if [[ $line == *");"* ]] && [ "$inside_block" = true ]; then
      inside_block=false
      key="${ALIAS}_${current_platform}"
      FIREBASE_OPTIONS["$key"]="${FIREBASE_OPTIONS["$key"]}${output_for_current_platform}"
      output_for_current_platform=""
    fi
  done < "$FILENAME"
}

generate_dart_code() {
  dart_code=""

  dart_code+="// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members, do_not_use_environment, constant_identifier_names\n"
  dart_code+="import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;\n"
  dart_code+="import 'package:flutter/foundation.dart'\n"
  dart_code+="    show TargetPlatform, defaultTargetPlatform, kIsWeb;\n\n"
  dart_code+="const flavorName = String.fromEnvironment('flavor');\n\n"
  dart_code+="class DefaultFirebaseOptions {\n"
  dart_code+="  static FirebaseOptions get currentPlatform {\n"
  dart_code+="    if (flavorName.isEmpty) {\n"
  dart_code+="      throw UnsupportedError(\n"
  dart_code+="        'No flavor specified. Please specify a flavor with dart-define-from-file.',\n"
  dart_code+="      );\n"
  dart_code+="    }\n\n"
  dart_code+="    if (kIsWeb) {\n"

  for key in "${!FIREBASE_OPTIONS[@]}"; do
    if [[ $key == *"web"* ]]; then
      alias=$(echo $key | cut -d'_' -f1)
      dart_code+="      if (flavorName == '$alias') {\n"
      dart_code+="        return _$key;\n"
      dart_code+="      }\n"
    fi
  done

  dart_code+="      throw UnsupportedError(\n"
  dart_code+="        'Flavor "\$flavorName" does not support Web.',\n"
  dart_code+="      );\n"
  dart_code+="    }\n\n"
  dart_code+="    switch (defaultTargetPlatform) {\n"
  dart_code+="      case TargetPlatform.android:\n"

  for key in "${!FIREBASE_OPTIONS[@]}"; do
    if [[ $key == *"android"* ]]; then
      alias=$(echo $key | cut -d'_' -f1)
      dart_code+="        if (flavorName == '$alias') {\n"
      dart_code+="          return _$key;\n"
      dart_code+="        }\n"
    fi
  done

  dart_code+="        throw UnsupportedError(\n"
  dart_code+="          'Flavor "\$flavorName" does not support Android.',\n"
  dart_code+="        );\n"
  dart_code+="      case TargetPlatform.iOS:\n"

  for key in "${!FIREBASE_OPTIONS[@]}"; do
    if [[ $key == *"ios"* ]]; then
      alias=$(echo $key | cut -d'_' -f1)
      dart_code+="        if (flavorName == '$alias') {\n"
      dart_code+="          return _$key;\n"
      dart_code+="        }\n"
    fi
  done

  dart_code+="        throw UnsupportedError(\n"
  dart_code+="         'Flavor "\$flavorName" does not support iOS.',\n"
  dart_code+="        );\n"
  dart_code+="      case TargetPlatform.macOS:\n"
  dart_code+="        throw UnsupportedError(\n"
  dart_code+="          'DefaultFirebaseOptions have not been configured for macos - '\n"
  dart_code+="          'you can reconfigure this by running the FlutterFire CLI again.',\n"
  dart_code+="        );\n"
  dart_code+="      case TargetPlatform.windows:\n"
  dart_code+="        throw UnsupportedError(\n"
  dart_code+="          'DefaultFirebaseOptions have not been configured for windows - '\n"
  dart_code+="          'you can reconfigure this by running the FlutterFire CLI again.',\n"
  dart_code+="        );\n"
  dart_code+="      case TargetPlatform.linux:\n"
  dart_code+="        throw UnsupportedError(\n"
  dart_code+="          'DefaultFirebaseOptions have not been configured for linux - '\n"
  dart_code+="          'you can reconfigure this by running the FlutterFire CLI again.',\n"
  dart_code+="        );\n"
  dart_code+="      // ignore: no_default_cases\n"
  dart_code+="      default:\n"
  dart_code+="        throw UnsupportedError(\n"
  dart_code+="          'DefaultFirebaseOptions are not supported for this platform.',\n"
  dart_code+="        );\n"
  dart_code+="    }\n"
  dart_code+="  }\n\n"

  for key in "${!FIREBASE_OPTIONS[@]}"; do
    option="${FIREBASE_OPTIONS[$key]}"
    dart_code+="  static const FirebaseOptions _$key = $option\n"
  done

  dart_code+="}\n"

  echo -e "$dart_code"
}

# Main part:

read -p "Please enter the App Name: " APP_NAME

cd "${SCRIPT_DIR}/flutter"

IFS=$'\n'
for LINE in $(jq -r '.projects | to_entries[] | "\(.key) \(.value)"' $FIREBASERC_PATH); do
  IFS=' ' read -r ALIAS PROJECT <<< "$LINE"
  generate_dart_define "$ALIAS" "$APP_NAME"
  flutterfire configure -y --project=$PROJECT --out="${FIREBASE_OPTIONS_TMP_PATH}/${ALIAS}.dart"
  generate_firebase_options $ALIAS "${FIREBASE_OPTIONS_TMP_PATH}/${ALIAS}.dart"
done

generate_dart_code > "$FIREBASE_OPTIONS_DART_PATH"

rm -rf "${SCRIPT_DIR}/tmp"
