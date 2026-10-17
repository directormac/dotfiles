{
  lib,
  cmake,
  fetchFromGitHub,
  libei,
  libxkbcommon,
  ninja,
  pkg-config,
  qt6,
  stdenv,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  buildInputs = [
    qt6.qtbase
    wayland
    libxkbcommon
    libei
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  pname = "hypr-kdeconnect-fix";

  # Whitelist Valent app IDs alongside official KDE Connect app IDs and NixOS paths
  postPatch = ''
    substituteInPlace src/security_policy.hpp \
      --replace-fail '|| normalized == QStringLiteral("org.kde.kdeconnect.sms");' \
                     '|| normalized == QStringLiteral("org.kde.kdeconnect.sms") || normalized == QStringLiteral("ca.andyholmes.Valent") || normalized == QStringLiteral("ca.andyholmes.Valent.desktop");' \
      --replace-fail 'inline bool isAllowedFallbackExecutablePath(const QString& executablePath) {' \
                     'inline bool isAllowedFallbackExecutablePath(const QString& executablePath) { if (executablePath.startsWith(QStringLiteral("/nix/store/"))) { return executablePath.endsWith(QStringLiteral("/kdeconnectd")) || executablePath.endsWith(QStringLiteral("/.kdeconnectd-wrapped")) || executablePath.endsWith(QStringLiteral("/valent")) || executablePath.endsWith(QStringLiteral("/.valent-wrapped")); }' \
      --replace-fail 'return senderPid == kdeConnectOwnerPid || senderPid == kdeConnectDaemonOwnerPid;' \
                     'if (executablePath.contains(QStringLiteral("valent"))) return true; return senderPid == kdeConnectOwnerPid || senderPid == kdeConnectDaemonOwnerPid;'
  '';

  src = fetchFromGitHub {
    hash = "sha256-fswdn3iq1iCXALLWC/p5EgRYbHIMgNHWEhxEtbHtCFY=";
    owner = "gfhdhytghd";
    repo = "hypr-kdeconnect-fix";
    rev = "362b904235c1b1d679eef73cbd5ad08d313d8954";
  };

  version = "0.1.0-unstable-2026-10-03";

  meta = with lib; {
    description = "RemoteDesktop portal bridge for KDE Connect / Valent remote input on Hyprland";
    homepage = "https://github.com/gfhdhytghd/hypr-kdeconnect-fix";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
