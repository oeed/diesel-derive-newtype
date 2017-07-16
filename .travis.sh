#!/bin/bash

# This is the script that's executed by travis, you can run it yourself to run
# the exact same suite

set -e

channel() {
    if [ -n "${TRAVIS}" ]; then
        if [ "${TRAVIS_RUST_VERSION}" = "${CHANNEL}" ]; then
            pwd
            (set -x; cargo "$@")
        fi
    elif [ -n "${APPVEYOR}" ]; then
        if [ "${APPVEYOR_RUST_CHANNEL}" = "${CHANNEL}" ]; then
            pwd
            (set -x; cargo "$@")
        fi
    else
        pwd
        (set -x; cargo "+${CHANNEL}" "$@")
    fi
}

run_test() {
  cargo clean
  channel test -v
}

run_clippy() {
    if [ "${TRAVIS_RUST_VERSION}" != "${CHANNEL}" ] ; then
        return
    fi
    # cached installation will not work on a later nightly
    if [ -n "${TRAVIS}" ] && ! cargo install clippy --debug --force; then
        echo "COULD NOT COMPILE CLIPPY, IGNORING CLIPPY TESTS"
        exit
    fi

    cargo clippy -- -Dclippy
}

CHANNEL=nightly
if [ "x${CLIPPY}" = xy ] ; then
    run_clippy
else
    run_test
fi

CHANNEL=beta
run_test

CHANNEL=stable
run_test
