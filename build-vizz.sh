#!/bin/sh
# Build Vizz 1.0 from this repo (BRIEF.md, steps 1, 4 and 5): Skiff v1.4 + patches/, the release package, every
# test, the one-file installer, out/. Linux x86-64 (or WSL), with git, curl, python3, pip, a C compiler; node for the
# web tests. Needs to reach github.com, gitee.com (the AC79 SDK) and pkgman.jieliapp.com (the toolchain; it
# redirects to jl-update.oss-cn-shenzhen.aliyuncs.com).
#   ./build-vizz.sh [WORKDIR]          (default: ../vizz-build; the Skiff clone goes there)
#   JIELI_TOOLCHAIN, AC79_SDK          as Skiff's build.sh (default: ~/.jieli/toolchain, ~/fw-AC79_AIoT_SDK)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
W="${1:-$HERE/../vizz-build}"
VER=1.0
mkdir -p "$W"
W="$(cd "$W" && pwd)"
export JIELI_TOOLCHAIN="${JIELI_TOOLCHAIN:-$HOME/.jieli/toolchain}"
export AC79_SDK="${AC79_SDK:-$HOME/fw-AC79_AIoT_SDK}"

# 1. Skiff v1.4 and Vizz's commits on it
[ -d "$W/skiff/.git" ] || git clone https://github.com/illuminus5/skiff.git "$W/skiff"
cd "$W/skiff"
git am --abort 2>/dev/null || true
git checkout -q -f -B vizz v1.4
git -c user.name="${GIT_AUTHOR_NAME:-vizz}" -c user.email="${GIT_AUTHOR_EMAIL:-vizz@localhost}" am -q -3 "$HERE"/patches/*.patch

# 4. what the build needs (Skiff's BUILDING.md)
[ -x "$JIELI_TOOLCHAIN/pi32v2/bin/clang" ] || tools/get_toolchain.sh "$(dirname "$JIELI_TOOLCHAIN")"
[ -f "$AC79_SDK/cpu/wl82/tools/uboot.boot" ] ||
    git clone --depth 1 --branch AC79NN_SDK_V1.2.1_2023-12-13 https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK.git "$AC79_SDK"
python3 -c 'import PIL, fontTools' 2>/dev/null || pip install Pillow fonttools
[ -d assets/samples-cc0/PIANO ] || python3 tools/fetch_cc0.py   # (the sets the build uses are in Skiff's tree)

# the release (build/vizz-1.0.fwsc, FM-1_810), then the development build the tests read (build/felucca.fwsc)
./build.sh --release "$VER"
rm -rf "$HERE/out"
mkdir -p "$HERE/out"
cp "build/vizz-$VER.fwsc" "$HERE/out/"
cp -R "build/release-$VER/LICENSE" "build/release-$VER/LICENSING.md" "build/release-$VER/LICENSES" "$HERE/out/"
cp "build/release-$VER"/ATTRIBUTION*.txt "$HERE/out/"
python3 web/make_vizz_installer.py "build/vizz-$VER.fwsc" "$VER" "$HERE/out/vizz-installer.html"
./build.sh
tests/run_tests.sh 2>&1 | tee "$W/test-log.txt"
tail -1 "$W/test-log.txt" | grep -q "ALL HOST TESTS PASSED"

# 5. the checksums
cd "$HERE/out"
sha256sum "vizz-$VER.fwsc" vizz-installer.html > SHA256SUMS
cat SHA256SUMS
ls -l "vizz-$VER.fwsc"
echo "out/: done; the test log: $W/test-log.txt"
