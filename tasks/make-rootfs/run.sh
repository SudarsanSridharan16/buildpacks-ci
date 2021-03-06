#!/bin/bash -l

set -o errexit
set -o nounset
set -o pipefail

set -x

buildpacks-ci/scripts/start-docker

pushd rootfs
  old_receipt_copy="receipt.${STACK}.x86_64.copy"
  mv "receipt.${STACK}.x86_64" "$old_receipt_copy"

  make --always-make NAME="$STACK"

  versioned_stack_filename="../rootfs-artifacts/$STACK-$(cat ../version/number).tar.gz"
  mv "$STACK.x86_64.tar.gz" "$versioned_stack_filename"

  versioned_receipt_filename="../receipt-artifacts/receipt.${STACK}.x86_64-$(cat ../version/number)"
  mv "receipt.${STACK}.x86_64" "$versioned_receipt_filename"

  which git
  TERM=xterm-color git --no-pager diff "$old_receipt_copy" "$versioned_receipt_filename" || true
popd
