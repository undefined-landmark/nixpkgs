{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.qbittorrent;
  inherit (lib)
    mkOption
    mkIf
    mkMerge
    optionals
    ;
  inherit (lib.types)
    str
    path
    listOf
    nullOr
    ;
in
{
  port = 8090;

  extraOpts = {
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
      type = listOf str;
      default = [ ];
      description = ''
        All available environment variables can be found in the
        [README.md](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables).

        Use the option `environmentFile` for sensitive variables, such as
        `QBITTORRENT_PASSWORD`.
      '';
    };

    environmentFile = mkOption {
      type = path;
      description = ''
        An environment file containing at least the variable
        `QBITTORRENT_PASSWORD`.

        All available environment variables can be found in the
        [README.md](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables).
      '';
    };
  };

  serviceOpts = mkMerge (
    [
      {
        serviceConfig = {
          ExecStart = "${pkgs.prometheus-qbittorrent-exporter}/bin/qbit-exp";
          Environment =
            optionals (cfg.url != null) [ "QBITTORRENT_BASE_URL=${cfg.url}" ]
            ++ optionals (cfg.user != null) [ "QBITTORRENT_USERNAME=${toString cfg.user}" ]
            ++ cfg.environment;
          EnvironmentFile = cfg.environmentFile;
        };
      }
    ]
    ++ [
      (mkIf config.services.qbittorrent.enable {
        after = [ "qbittorrent.service" ];
        requires = [ "qbittorrent.service" ];
      })
    ]
  );
}
