#!/bin/bash
# Autoreloads go application on file changes
# From https://github.com/caitlinelfring/go_autoreload

FILES_TO_WATCH=${1:-"./*.go"}

wait_for_changes() {
  echo "Waiting for changes"
  if [ "$(uname)" == "Darwin" ]; then
    fswatch -e ".*" -i "\\.go$" -x -r -1 .
  else
    # FILES_TO_WATCH can be something like: ./*.go ./**/*.go ./**/**/*.go
    # depending on how long the folder structure is.
    # unfortunately, inotifywait can't recursively watch specific file types
    inotifywait -e modify -e create -e delete -e move $FILES_TO_WATCH
  fi
}

tests() {
  echo "Running tests"
  go test ./...
}

run() {
  echo "Running..."
  go run main.go -c example.yaml --debug
}

# Exit on ctrl-c (without this, ctrl-c would go to inotifywait, causing it to
# reload instead of exit):
trap "exit 0" SIGINT SIGTERM

run
while wait_for_changes; do
  run
done
