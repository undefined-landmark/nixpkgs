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

    username = mkOption {
      type = nullOr str;
      default = "admin";
      description = ''
        qBittorrent username.
      '';
    };

    environment = mkOption {
      type = attrsOf str;
      default = { };
      description = ''
        All available environment variables can be found in the
        [README.md](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables).

        Use the option `passwordFile` to set the qBittorrent password.
      '';
      example = {
        ENABLE_TRACKER = "true";
      };
    };

    passwordFile = mkOption {
      type = nullOr path;
      description = ''
        Path to a file containing the qBittorrent password.
      '';
    };
  };

  serviceOpts = {
    serviceConfig = {
      ExecStart = getExe cfg.package;
      LoadCredential = "qbitPass:${cfg.passwordFile}";
    };
    environment = {
      EXPORTER_PORT = toString cfg.port;
      QBITTORRENT_USERNAME = cfg.user;
      QBITTORRENT_BASE_URL = cfg.url;
      QBITTORRENT_PASSWORD_FILE = "\${CREDENTIAL_DIRECTORY}/qbitPass";
    }
    // cfg.environment;
  }
  // optionalAttrs config.services.qbittorrent.enable {
    after = [ "qbittorrent.service" ];
    requires = [ "qbittorrent.service" ];
  };
}
