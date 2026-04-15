#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

log() {
  printf "\n[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

size_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    du -sh "$path" 2>/dev/null | awk '{print $1 "\t" $2}'
  fi
}

show_sizes() {
  log "Current project cache/build sizes"
  for p in \
    .dart_tool \
    build \
    android/.gradle \
    android/app/build \
    ios/Pods \
    ios/build \
    macos/Pods \
    macos/build \
    linux/build \
    windows/build; do
    size_if_exists "$p"
  done
}

require_flutter() {
  if ! command -v flutter >/dev/null 2>&1; then
    echo "flutter not found in PATH"
    echo "Please open a shell where Flutter is installed, or export PATH/FLUTTER_ROOT first."
    exit 1
  fi
}

clean_project() {
  log "Cleaning project-local build/cache artifacts"
  rm -rf .dart_tool build
  rm -rf android/.gradle android/app/build
  rm -rf ios/Pods ios/build
  rm -rf macos/Pods macos/build
  rm -rf linux/build windows/build

  if [ -f android/gradlew ]; then
    log "Running Gradle clean"
    (
      cd android
      chmod +x ./gradlew
      ./gradlew clean || true
    )
  fi

  flutter clean || true
}

usage() {
  cat <<'EOF'
Usage:
  ./safe_flutter_run.sh [flutter run args...]

Examples:
  ./safe_flutter_run.sh
  ./safe_flutter_run.sh -d chrome
  ./safe_flutter_run.sh -d emulator-5554 --debug

What it does:
  1. Removes project-local Flutter/Gradle/Xcode build junk
  2. Runs flutter pub get
  3. Starts flutter run with any args you pass through
  4. Prints cache/build sizes before and after
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_flutter
show_sizes
clean_project
show_sizes

log "Running flutter pub get"
flutter pub get

log "Starting flutter run $*"
flutter run "$@"

log "flutter run exited"
show_sizes
log "Tip: rerun this script anytime to reset local build/cache files before the next run"
