#!/usr/bin/env bash
set -e

cd "$(dirname $0)/.."

VER="$1"
if [ -z "$VER" ]; then
    echo "Must set version for release"
    echo "Usage:" "$0" "<version>"
    exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$BRANCH" != "main" ]]; then
    echo "Branch must be 'main'";
    exit 1
fi

if [ ! -z "$(git status --porcelain)" ]; then
    echo "Working dir mush be clean"
    exit 1
fi

function publish {
    echo "Publishing to Hex" "$VER"
    mix hex.publish
    echo "Tagging" "$VER"
    git tag "$VER"
    git push origin "$VER"
    echo "🚀"
}

echo "Version set to:" "$VER"
while true; do
    read -p "Do you wish to publish? [Yn] " yn
    case $yn in
        [Yy]* ) publish; break;;
        [Nn]* ) echo "canceling..." ; exit;;
        * ) publish; break;;
    esac
done
