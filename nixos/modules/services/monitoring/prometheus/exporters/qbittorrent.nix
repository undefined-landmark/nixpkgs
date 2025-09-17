{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.qbittorrent;
  inherit (lib)
    getExe
    mkOption
    mkPackageOption
    optionalAttrs
    ;
  inherit (lib.types)
    str
    path
    attrsOf
    nullOr
    ;
in
{
  port = 8090;

  extraOpts = {
    package = mkPackageOption pkgs "prometheus-qbittorrent-exporter" { };

    url = mkOption {
      type = nullOr str;
      default = "http://localhost:8080";
      description = ''
        Url where qbittorrent is running.
      '';
    };

    user = mkOption {
      type = nullOr str;
      default = "admin";
      description = ''
        User to connect to qbittorrent server.
      '';
    };

    environment = mkOption {
      type = attrsOf str;
      default = { };
      description = ''
        All available environment variables can be found in the
        [README.md](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables).

        Use the option `environmentFile` for sensitive variables, such as
        `QBITTORRENT_PASSWORD`.
      '';
      example = {
        ENABLE_TRACKER = "true";
      };
    };

    environmentFile = mkOption {
      type = path;
      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        The file should contain at least the variable `QBITTORRENT_PASSWORD`.

        All available environment variables can be found in the
        [README.md](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables).
      '';
    };
  };

  serviceOpts = {
    serviceConfig = {
      ExecStart = getExe pkgs.prometheus-qbittorrent-exporter;
      EnvironmentFile = cfg.environmentFile;
    };
    environment = {
      EXPORTER_PORT = toString cfg.port;
      QBITTORRENT_USERNAME = cfg.user;
      QBITTORRENT_BASE_URL = cfg.url;
    }
    // cfg.environment;
  }
  // optionalAttrs config.services.qbittorrent.enable {
    after = [ "qbittorrent.service" ];
    requires = [ "qbittorrent.service" ];
  };
}
