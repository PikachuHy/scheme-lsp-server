#!/bin/sh

BASE_DIR=$(dirname $0)
SOURCE_DIR=${BASE_DIR}/..

echo -n "Checking for existing installation...   "
gsi -e '(import (codeberg.org/rgherdt/scheme-lsp-server lsp-server private gambit)) (exit)' >/dev/null
if [ $? -ne 0 ]; then
    echo "not found."
    echo "This scripts only compiles an existing installation of the library."
    echo "Please follow the install instructions and run this script again."
    exit 1
fi

echo "found."
echo "Building installed modules."

gsc codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/gambit \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/util \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/parse \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/adapter \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/trie \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/compat \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/file \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/document \
    codeberg.org/rgherdt/scheme-lsp-server/lsp-server

echo "Compiling gambit-lsp-server executable."

gsc -exe -nopreload ${SOURCE_DIR}/gambit/gambit-lsp-server.scm
