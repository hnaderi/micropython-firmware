{ stdenv, lib, fetchFromGitHub, pkg-config, cmake, python3, libffi, readline }:

stdenv.mkDerivation rec {
  pname = "firmware";
  version = "0.0.1";

  srcs = [
    (fetchFromGitHub {
      owner = "micropython";
      repo = "micropython";
      rev = "v1.22.2";
      sha256 = "sha256-sdok17HvKub/sI+8cAIIDaLD/3mu8yXXqrTOej8/UfU=";
      fetchSubmodules = true;
      name = "micropython";
    })
    (fetchFromGitHub {
      owner = "russhughes";
      repo = "st7789_mpy";
      rev = "4d218c1f7591fe8a5e562fba0e1d6aedc2129168";
      sha256 = "sha256-RRvnoCV25hjvMWJSBwOlVoB8aMUUo1spnyNUMrKdRDo=";
      name = "st7789_mpy";
    })
  ];

  sourceRoot = "micropython";

  nativeBuildInputs = [ pkg-config python3 ];

  buildInputs = [ libffi readline cmake ];
  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild
    make -C mpy-cross
    make -C ports/unix

    cd ports/rp2
    # make submodules
    make clean
    make

    runHook postBuild
  '';

  doCheck = true;

  skippedTests = " -e select_poll_fd"
    + lib.optionalString (stdenv.isDarwin && stdenv.isAarch64)
    " -e ffi_callback"
    + lib.optionalString (stdenv.isLinux && stdenv.isAarch64) " -e float_parse";

  checkPhase = ''
    runHook preCheck
    pushd tests
    ${python3.interpreter} ./run-tests.py ${skippedTests}
    popd
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 ports/unix/build-standard/micropython -t $out/bin
    install -Dm755 mpy-cross/build/mpy-cross -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A lean and efficient Python implementation for microcontrollers and constrained systems";
    homepage = "https://micropython.org";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ prusnak sgo ];
  };
}
