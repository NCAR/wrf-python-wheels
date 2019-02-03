# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]
# See env_vars.sh for extra environment variables
source gfortran-install/gfortran_utils.sh

function pre_build {
    pushd $REPO_DIR/fortran/build_help
    gfortran -o sizes -fopenmp omp_sizes.f90
    python sub_sizes.py
    popd

    pushd $REPO_DIR/fortran
    gfortran -E ompgen.F90 -fopenmp -cpp -o omp.f90
    popd
}

function build_wheel {
    export FFLAGS="-fPIC -fopenmp -mtune=generic"
    export LDFLAGS="-fPIC -fopenmp"
    if [ -z "$IS_OSX" ]; then
        export LDFLAGS="$LDFLAGS -shared -Wl,-strip-all"
        build_pip_wheel $@
    else
        build_osx_wheel $@
    fi
}

function set_arch {
    local arch=$1
    export CC="clang $arch"
    export CXX="clang++ $arch"
    export CFLAGS="$CFLAGS $arch"
    export FFLAGS="$FFLAGS $arch"
    export FARCH="$arch"
    export LDFLAGS="$LDFLAGS $arch"
}

function build_osx_wheel {
    # Build 64-bit wheel
    # Standard gfortran won't build dual arch objects.
    local repo_dir=${1:-$REPO_DIR}
    local py_ld_flags="-Wall -undefined dynamic_lookup -bundle -fopenmp"

    install_gfortran
    # 64-bit wheel
    local arch="-m64"
    set_arch $arch
    # Build wheel
    #export FFLAGS="$FFLAGS -fPIC"
    export LDSHARED="$CC $py_ld_flags"
    export LDFLAGS="$arch $py_ld_flags"
    build_pip_wheel "$repo_dir"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import wrf"
    # $REPO_DIR not available here, see multibuild/travis_linux_steps.sh (install_run)
    local repo_dir="../wrf-python"
    pushd $repo_dir/test/ci_tests
    python utests.py
    popd
}
