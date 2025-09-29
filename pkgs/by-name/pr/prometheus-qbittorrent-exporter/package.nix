{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests
}:

buildGoModule rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = "qbittorrent-exporter";
    tag = "v${version}";
    hash = "sha256-9J4nGG52M7SSeXigLBJK/dqXRvSpPqOGRJ8BQx7+1eU=";
  };

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
