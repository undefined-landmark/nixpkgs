{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = "qbittorrent-exporter";
    rev = "v${version}";
    hash = "sha256-Rv1UuvWfQzHQ82ZKfLWnxhCWYhALy3CuLL6nUzeNugc=";
  };

  sourceRoot = "${src.name}/src";

  vendorHash = "sha256-21/L4etH/xi3q69FCsYxAKui4PhPN1c+vZt3ZNnI0+8=";

  ldflags = [
    "-s"
    "-w"
    "-X 'qbit-exp/app.version=v${version}'"
  ];

  postInstall = ''
    mv $out/bin/qbit-exp $out/bin/prometheus-qbittorrent-exporter
  '';

  meta = {
    description = "A fast and lightweight prometheus exporter for qBittorrent";
    homepage = "https://github.com/undefined-landmark/qbittorrent-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ undefined-landmark ];
    mainProgram = "prometheus-qbittorrent-exporter";
  };
}
