#!/bin/bash
# Source: https://github.com/stevehoover/warp-v by @stevehoover
# @adumont: I have trimmed some stuff off (SymbiYosys, Boolector)

# A script to build the environment needed for formal verification of warp-v using riscv-formal.
# The build is performed in a 'env_build' directory within the current working directory, and
# installed in an 'env' directory also within the current working directory. Each tool is built
# in its own directory within 'env_build'. If this directory already exists, the tool will not
# be built. Each tool is built sequentially even if preceding builds failed. Passing tools will
# touch a "PASSED" file in their directory, and the entire script will touch "PASSED" in /env.

die() { echo "$*" 1>&2 ; exit 1; }
skip() { true; }  # Use this to skip a command.
comment() { true; } # This can be used for comments within multiline commands.

# Check to see whether the given tool has already been built, and whether it passed.
# Return 1 if the tool must be built (o.w. 0).
check_previous_build() {
  cd "$BUILD_DIR"
  if [ -e "$1" ]; then
    if [ -e "$1/PASSED" ]; then
      echo && echo "Info: Skipping $1 build, which previously passed." && echo
      STATUS[$1]=0
    else
      echo && \
      echo "*******************************************************" && \
      echo "Warning: Skipping $1 build, which previously FAILED." && \
      echo "*******************************************************" && \
      echo
      STATUS[$1]=1
    fi
    return 0
  else
    echo && \
    echo "------------------------" && \
    echo "Info: Building $1." && \
    echo
    return 1
  fi
}

# Record the commit ID of the latest yosys.
git ls-remote --heads https://github.com/cliffordwolf/yosys.git refs/heads/master | cut -f1 > yosys_latest_commit_id.txt

# If env is not provided by the cache and marked passed, remove any cached env results and build it.
cd ${TRAVIS_BUILD_DIR}/ci
[ -e env/PASSED ] && echo "Build env was cached" && exit
rm -rf env/*
mkdir -p env/bin env/share env_build || die "Failed to make 'env' directories."
cd env_build

BUILD_DIR=`pwd`
echo "Build dir: $BUILD_DIR"

# Yosys:
check_previous_build "yosys"
if [ $? -eq 1 ]; then
  git clone https://github.com/cliffordwolf/yosys.git && \
  cd yosys && \
  comment 'Capture the commit ID' && \
  (git rev-parse HEAD > ../../env/yosys_commit_id.txt) && \
  make config-clang && \
  make && \
  echo "pwd of env_build/yosys: $PWD" && \
  mv yosys* ../../env/bin && \
  mv share/* ../../env/share && \
  touch PASSED
  STATUS[yosys]=$?
fi

cd "$BUILD_DIR"
if (( ${STATUS[yosys]} || ${STATUS[SymbiYosys]} || ${STATUS[boolector]} )); then
  echo && \
  echo "*********************" && \
  echo "Some build(s) FAILED." && \
  echo "*********************" && \
  # echo "(${STATUS[yosys]}, ${STATUS[SymbiYosys]}, ${STATUS[boolector]})"
  echo "(${STATUS[yosys]})"
  echo `ls */PASSED` && \
  echo
  exit 1
else
  touch ../env/PASSED
  exit 0
fi