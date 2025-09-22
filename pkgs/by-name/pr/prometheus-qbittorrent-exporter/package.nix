{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests
}:

buildGoModule rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.11.0-FILE";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = "qbittorrent-exporter";
    rev = "d6aef64118278b6b4aa0b200359c3bc2f772f8f3";
    hash = "sha256-I9qq9GsN8RPI8qVLetb71AtO49j2dVA+Kpp7INTWJSU=";
  };

  postPatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.25.1' 'go 1.25'
  '';

  sourceRoot = "${src.name}/src";

  vendorHash = "sha256-jJmhRnjioeTq9Uol0lYLChPi4O1D9JnGqN7q1XK36yE=";

  ldflags = [
    "-s"
    "-X 'qbit-exp/app.version=v${version}'"
  ];

  postInstall = ''
    mv $out/bin/qbit-exp $out/bin/prometheus-qbittorrent-exporter
  '';

  passthru = {
    tests.testService = nixosTests.prometheus-exporters.qbittorrent;
  };

  meta = {
    description = "A fast and lightweight prometheus exporter for qBittorrent";
    homepage = "https://github.com/undefined-landmark/qbittorrent-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ undefined-landmark ];
    mainProgram = "prometheus-qbittorrent-exporter";
  };
}
