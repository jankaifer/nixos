#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq unzip

set -euo pipefail

N="$1.$2"
VER="$3"

# Create a tempdir for the extension download
EXTTMP=$(mktemp -d -t vscode_exts_XXXXXXXX)

URL="https://$1.gallery.vsassets.io/_apis/public/gallery/publisher/$1/extension/$2/$VER/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
echo "$URL"

# Quietly but delicately curl down the file, blowing up at the first sign of trouble.
curl --silent --show-error --fail -X GET -o "$EXTTMP/$N.zip" "$URL"
# Unpack the file we need to stdout then pull out the version
VER=$(jq -r '.version' <(unzip -qc "$EXTTMP/$N.zip" "extension/package.json"))
# Calculate the SHA
SHA=$(nix-hash --flat --base32 --type sha256 "$EXTTMP/$N.zip")

# Clean up.
rm -Rf "$EXTTMP"
# I don't like 'rm -Rf' lurking in my scripts but this seems appropriate

cat <<-EOF
{
    name = "$2";
    publisher = "$1";
    version = "$VER";
    sha256 = "$SHA";
}