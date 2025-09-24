{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests
}:

buildGoModule rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = "qbittorrent-exporter";
    tag = "v${version}";
    hash = "";
  };

  sourceRoot = "${src.name}/src";

  vendorHash = "";

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
