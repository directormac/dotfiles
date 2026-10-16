{
  lib,
  cmake,
  expat,
  fetchFromGitHub,
  fontconfig,
  freefont_ttf,
  libGL,
  libX11,
  libXScrnSaver,
  libXcursor,
  libXdmcp,
  libXext,
  libXi,
  libXinerama,
  libXpresent,
  libXrandr,
  libbfd,
  libffi,
  libsamplerate,
  libxkbcommon,
  nanosvg,
  nettle,
  pipewire,
  pkg-config,
  pulseaudio,
  spice-protocol,
  stdenv,
  wayland,
  wayland-protocols,
  wayland-scanner,
  openGLSupport ? true,
  pipewireSupport ? true,
  pulseSupport ? true,
  waylandSupport ? true,
  xorgSupport ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  buildInputs = [
    libX11
    libGL
    freefont_ttf
    spice-protocol
    expat
    libbfd
    nettle
    fontconfig
    libffi
    nanosvg
  ]
  ++ lib.optionals xorgSupport [
    libxkbcommon
    libXi
    libXScrnSaver
    libXinerama
    libXcursor
    libXpresent
    libXext
    libXrandr
    libXdmcp
  ]
  ++ lib.optionals waylandSupport [
    libxkbcommon
    wayland
    wayland-protocols
  ]
  ++ lib.optionals pipewireSupport [
    pipewire
    libsamplerate
  ]
  ++ lib.optionals pulseSupport [
    pulseaudio
    libsamplerate
  ];

  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=OFF"
  ]
  ++ lib.optionals (!openGLSupport) [ "-DENABLE_OPENGL=no" ]
  ++ lib.optionals (!xorgSupport) [ "-DENABLE_X11=no" ]
  ++ lib.optionals (!waylandSupport) [ "-DENABLE_WAYLAND=no" ]
  ++ lib.optionals (!pulseSupport) [ "-DENABLE_PULSEAUDIO=no" ]
  ++ lib.optionals (!pipewireSupport) [ "-DENABLE_PIPEWIRE=no" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  patches = [
    ./nanosvg-unvendor.diff
  ];

  pname = "looking-glass-client";

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp $src/resources/lg-logo.png $out/share/pixmaps
  '';

  postUnpack = ''
    echo ${finalAttrs.src.rev} > source/VERSION
    export sourceRoot="source/client"
  '';

  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-SakFCEXPsJW3zmNpmklK8ZCGpcJzJ/4v7TJDpjWqVeA=";
    owner = "gnif";
    repo = "LookingGlass";
    rev = "53bfb6547f2b7abd6c183192e13a57068c1677ea";
  };

  version = "B7";

  meta = with lib; {
    description = "KVM Frame Relay (KVMFR) implementation";
    homepage = "https://looking-glass.io/";
    license = licenses.gpl2Plus;

    longDescription = ''
      Looking Glass is an open source application that allows the use of a KVM
      (Kernel-based Virtual Machine) configured for VGA PCI Pass-through
      without an attached physical monitor, keyboard or mouse. This is the final
      step required to move away from dual booting with other operating systems
      for legacy programs that require high performance graphics.
    '';

    mainProgram = "looking-glass-client";

    maintainers = with maintainers; [
      alexbakker
      babbaj
      j-brn
    ];

    platforms = [ "x86_64-linux" ];
  };
})
