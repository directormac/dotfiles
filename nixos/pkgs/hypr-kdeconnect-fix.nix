{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  wayland,
  wayland-scanner,
  libxkbcommon,
  libei,
}:

stdenv.mkDerivation {
  pname = "hypr-kdeconnect-fix";
  version = "0.1.0-unstable-2026-10-03";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "hypr-kdeconnect-fix";
    rev = "362b904235c1b1d679eef73cbd5ad08d313d8954";
    hash = "sha256-fswdn3iq1iCXALLWC/p5EgRYbHIMgNHWEhxEtbHtCFY=";
  };

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

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qt6.qtbase
    wayland
    libxkbcommon
    libei
  ];

  meta = with lib; {
    description = "RemoteDesktop portal bridge for KDE Connect / Valent remote input on Hyprland";
    homepage = "https://github.com/gfhdhytghd/hypr-kdeconnect-fix";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
