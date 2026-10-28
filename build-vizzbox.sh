#!/bin/sh
# Build Vizzbox 1.0 from this repo (BRIEF-VIZZBOX.md; after build-vizz.sh, Vizz 2.0's): Skiff v2.0.1 + patches/ (Vizz
# 2.0's five and the Vizzbox's), the release package vizzbox-1.0.fwsc (FM-1_850), the converter, the one-file
# installer vizzbox-installer.html, every test (tests/run_tests.sh, the installers in Chromium, both counter-checks),
# out/, and with DEMOS=1 demos/ (an MP3 and the MIDI file of every subgenre, the Vizzbox in the browser as one file).
# Linux x86-64 (or WSL), with git, curl, python3 (numpy for the demos), pip, a C compiler, node; for the converter and
# the browser version Emscripten (emcc; fetched into ~/emsdk when missing), for the browser tests Playwright with its
# Chromium (skipped without), for the demos ffmpeg. Needs to reach github.com, gitee.com (the AC79 SDK),
# pkgman.jieliapp.com (the toolchain; it redirects to jl-update.oss-cn-shenzhen.aliyuncs.com) and, for emsdk,
# storage.googleapis.com.
#   ./build-vizzbox.sh [WORKDIR]       (default: ../vizzbox-build; the Skiff clone goes there)
#   JIELI_TOOLCHAIN, AC79_SDK          as Skiff's build.sh (default: ~/.jieli/toolchain, ~/fw-AC79_AIoT_SDK)
#   EMSDK                              an Emscripten SDK (default: ~/emsdk, version EMSDK_VERSION)
#   VIZZ10_CHECK=0                     skip rebuilding Vizz 1.0 (branch vizz-1.0) for the installer test's unit
#   MUTANTS=0                          skip the counter-checks (tests/vizz_mutants.py, tests/vizzbox_mutants.py, ~30 min)
#   DEMOS=1                            make demos/ again (tools/vizzbox_demos.py, web/emu/make_vizzbox_emu.py)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
W="${1:-$HERE/../vizzbox-build}"
VER=1.0
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

# 2. what the build needs (Skiff's BUILDING.md); Emscripten for the converter the installer carries (web/conv)
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

# 3. the release (build/vizzbox-1.0.fwsc, FM-1_850) and its converter, the installer, out/
./build.sh --release "$VER"
python3 tools/size_report.py build/felucca.elf 80 | tee "$W/size-report.txt"   # where the flash goes
sh web/conv/build.sh
rm -rf "$HERE/out"
mkdir -p "$HERE/out"
cp "build/vizzbox-$VER.fwsc" "$HERE/out/"
cp -R "build/release-$VER/LICENSE" "build/release-$VER/LICENSING.md" "build/release-$VER/LICENSES" "$HERE/out/"
cp "build/release-$VER"/ATTRIBUTION*.txt "$HERE/out/"
python3 web/make_vizzbox_installer.py "build/vizzbox-$VER.fwsc" "$VER" "$HERE/out/vizzbox-installer.html" build/conv/conv.wasm

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

# 4. the development build the tests read (build/felucca.fwsc), every test; the released installer in Chromium
./build.sh
tests/run_tests.sh 2>&1 | tee "$W/test-log.txt"
tail -1 "$W/test-log.txt" | grep -q "ALL HOST TESTS PASSED"
node web/test_vizzbox_installer.mjs "$HERE/out/vizzbox-installer.html" tests/vizz10_unit.json build/conv/conv.wasm \
    build/host/vizz-installer.html 2>&1 | tee "$W/installer-test-log.txt"
tail -1 "$W/installer-test-log.txt" | grep -q "all ok\|skipped"

# 5. the counter-checks: every deliberate fault caught (Vizz 2.0's and the Vizzbox's)
if [ "${MUTANTS:-1}" != 0 ]; then
    python3 tests/vizz_mutants.py 2>&1 | tee "$W/mutants-log.txt"
    tail -1 "$W/mutants-log.txt" | grep -q "every fault caught"
    python3 tests/vizzbox_mutants.py 2>&1 | tee "$W/vizzbox-mutants-log.txt"
    tail -1 "$W/vizzbox-mutants-log.txt" | grep -q "every fault caught"
fi

# 6. the demos (BRIEF-VIZZBOX.md 8): every subgenre rendered (seed 5EED, ENERGY 70, VARIATION 40, NORMAL), ~60 s from
# a BUILD into its DROP as MP3 and the whole song's MIDI file, demos/README.md's tables; the Vizzbox in the browser
if [ "${DEMOS:-0}" != 0 ]; then
    cc -O2 -ffp-contract=off -w -Ibuild/gen -Ifirmware/src -o build/host/vizzbox_render tools/vizzbox_render.c -lm
    mkdir -p "$HERE/demos"
    rm -f "$HERE"/demos/*.mp3 "$HERE"/demos/*.mid
    python3 tools/vizzbox_demos.py build/host/vizzbox_render "$HERE/demos" 2>&1 | tee "$W/demos-log.txt"
    rm -f "$HERE/demos/levels.tsv"
    cp build/emu_vizzbox/felucca.wasm "$W/vizzbox-emu.wasm"   # (tests/run_tests.sh built it with VIZZBOX=1)
    python3 web/emu/make_vizzbox_emu.py "$W/vizzbox-emu.wasm" "$VER" "$HERE/demos/vizzbox-im-browser.html"
    node web/emu/test_vizzbox_emu.mjs "$HERE/demos/vizzbox-im-browser.html"
fi

# 7. the checksums
cd "$HERE/out"
sha256sum "vizzbox-$VER.fwsc" vizzbox-installer.html > SHA256SUMS
cat SHA256SUMS
ls -l "vizzbox-$VER.fwsc"
echo "out/: done; the test logs: $W/test-log.txt, $W/installer-test-log.txt"
