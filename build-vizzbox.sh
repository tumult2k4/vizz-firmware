#!/bin/sh
# Build Vizzbox from this repo (BRIEF-VIZZBOX.md): Skiff v2.0.1 + patches/ (Vizz 2.0's five and Vizzbox's), the
# release package, the converter, the one-file installer, every test, out/. (Stage 1 of the brief: the base is
# Vizz 2.0; the release is still Vizz 2.0's until the Vizzbox name and identity come, and the flash is measured.)
# Linux x86-64 (or WSL), with git, curl, python3, pip, a C compiler, node; for
# the converter Emscripten (emcc; fetched into ~/emsdk when missing), for the installer's browser test Playwright with
# its Chromium (skipped without). Needs to reach github.com, gitee.com (the AC79 SDK), pkgman.jieliapp.com (the
# toolchain; it redirects to jl-update.oss-cn-shenzhen.aliyuncs.com) and, for emsdk, storage.googleapis.com.
#   ./build-vizzbox.sh [WORKDIR]       (default: ../vizzbox-build; the Skiff clone goes there)
#   JIELI_TOOLCHAIN, AC79_SDK          as Skiff's build.sh (default: ~/.jieli/toolchain, ~/fw-AC79_AIoT_SDK)
#   EMSDK                              an Emscripten SDK (default: ~/emsdk, version EMSDK_VERSION)
#   VIZZ10_CHECK=0                     skip rebuilding Vizz 1.0 (branch vizz-1.0) for the installer test's unit
#   MUTANTS=0                          skip the counter-check (tests/vizz_mutants.py, 4 minutes)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
W="${1:-$HERE/../vizzbox-build}"
VER=2.0
BASE=v2.0.1
EMSDK_VERSION="${EMSDK_VERSION:-6.0.13}"
mkdir -p "$W"
W="$(cd "$W" && pwd)"
export JIELI_TOOLCHAIN="${JIELI_TOOLCHAIN:-$HOME/.jieli/toolchain}"
export AC79_SDK="${AC79_SDK:-$HOME/fw-AC79_AIoT_SDK}"
export EMSDK="${EMSDK:-$HOME/emsdk}"

# 1. Skiff v2.0.1 and Vizz's and Vizzbox's commits on it
[ -d "$W/skiff/.git" ] || git clone https://github.com/illuminus5/skiff.git "$W/skiff"
cd "$W/skiff"
git am --abort 2>/dev/null || true
git checkout -q -f -B vizzbox-1.0 "$BASE"
git -c user.name="${GIT_AUTHOR_NAME:-vizz}" -c user.email="${GIT_AUTHOR_EMAIL:-vizz@localhost}" am -q -3 "$HERE"/patches/*.patch

# 5. what the build needs (Skiff's BUILDING.md); Emscripten for the converter the installer carries (web/conv)
[ -x "$JIELI_TOOLCHAIN/pi32v2/bin/clang" ] || tools/get_toolchain.sh "$(dirname "$JIELI_TOOLCHAIN")"
[ -f "$AC79_SDK/cpu/wl82/tools/uboot.boot" ] ||
    git clone --depth 1 --branch AC79NN_SDK_V1.2.1_2023-12-13 https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK.git "$AC79_SDK"
python3 -c 'import PIL, fontTools' 2>/dev/null || pip install Pillow fonttools
[ -d assets/samples-cc0/PIANO ] || python3 tools/fetch_cc0.py   # (the sets the build uses are in Skiff's tree)
if ! command -v emcc >/dev/null 2>&1; then
    [ -x "$EMSDK/emsdk" ] || git clone --depth 1 https://github.com/emscripten-core/emsdk.git "$EMSDK"
    "$EMSDK/emsdk" install "$EMSDK_VERSION" && "$EMSDK/emsdk" activate "$EMSDK_VERSION"
    . "$EMSDK/emsdk_env.sh"
    command -v emcc >/dev/null 2>&1 || PATH="$EMSDK/upstream/emscripten:$PATH"   # (emsdk_env.sh sets nothing under dash)
fi

# the release (build/vizz-2.0.fwsc, FM-1_820) and its converter, the installer; then the development build the tests
# read (build/felucca.fwsc)
./build.sh --release "$VER"
python3 tools/size_report.py build/felucca.elf 80 | tee "$W/size-report.txt"   # (Vizzbox) where the flash goes
sh web/conv/build.sh
rm -rf "$HERE/out"
mkdir -p "$HERE/out"
cp "build/vizz-$VER.fwsc" "$HERE/out/"
cp -R "build/release-$VER/LICENSE" "build/release-$VER/LICENSING.md" "build/release-$VER/LICENSES" "$HERE/out/"
cp "build/release-$VER"/ATTRIBUTION*.txt "$HERE/out/"
python3 web/make_vizz_installer.py "build/vizz-$VER.fwsc" "$VER" "$HERE/out/vizz-installer.html" build/conv/conv.wasm

# the installer test's unit (tests/vizz10_unit.json) made again by Vizz 1.0's own code: the same bytes
if [ "${VIZZ10_CHECK:-1}" != 0 ] && git -C "$HERE" rev-parse -q --verify origin/vizz-1.0 >/dev/null; then
    rm -rf "$W/vizz10" && git worktree prune && git worktree add -q --detach "$W/vizz10" v1.4
    mkdir -p "$W/vizz10-patches"
    git -C "$HERE" archive origin/vizz-1.0 patches | tar -x -C "$W/vizz10-patches"
    git -C "$W/vizz10" -c user.name=vizz -c user.email=vizz@localhost am -q -3 "$W"/vizz10-patches/patches/*.patch
    (cd "$W/vizz10" && ./build.sh > "$W/vizz10-build.log" 2>&1)
    sh tests/vizz10_fixture.sh "$W/vizz10" "$W/vizz10_unit.json"
    cmp "$W/vizz10_unit.json" tests/vizz10_unit.json
    echo "tests/vizz10_unit.json: made again from Vizz 1.0, the same bytes"
fi

./build.sh
tests/run_tests.sh 2>&1 | tee "$W/test-log.txt"
tail -1 "$W/test-log.txt" | grep -q "ALL HOST TESTS PASSED"
node web/test_vizz_installer.mjs "$HERE/out/vizz-installer.html" tests/vizz10_unit.json build/conv/conv.wasm 2>&1 |
    tee "$W/installer-test-log.txt"
tail -1 "$W/installer-test-log.txt" | grep -q "all ok\|skipped"
if [ "${MUTANTS:-1}" != 0 ]; then
    python3 tests/vizz_mutants.py 2>&1 | tee "$W/mutants-log.txt"
    tail -1 "$W/mutants-log.txt" | grep -q "every fault caught"
fi

# 6. the checksums
cd "$HERE/out"
sha256sum "vizz-$VER.fwsc" vizz-installer.html > SHA256SUMS
cat SHA256SUMS
ls -l "vizz-$VER.fwsc"
echo "out/: done; the test logs: $W/test-log.txt, $W/installer-test-log.txt"
