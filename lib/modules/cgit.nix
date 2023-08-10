{ config, pkgs, lib, modulesPath, ... }:

with lib;

let

  cfg = config.services.cgit;

  cgitConfigFile = pkgs.writeText "cgitrc" (generators.toKeyValue {} {
    css = "/cgit.css";
    logo = "/logo.png";
    favicon = "/favicon.ico";
    about-filter = "${cfg.cgitPackage}/lib/cgit/filters/about-formatting.sh";
    source-filter = "${cfg.cgitPackage}/lib/cgit/filters/syntax-highlighting.py";
    root-title = "git.ctsk.dev";
    scan-path = cfg.gitRoot;
  });


in {

  disabledModules = [
    (modulesPath + "/services/networking/cgit.nix")
  ];

  options.services.cgit = {
    enable = mkEnableOption "cgit";

    user = mkOption {
      type = types.str;
      default = "cgit";
      description = mdDoc ''
      User account under which the webserver for cgit runs
      ''; 
    };

    group = mkOption {
      type = types.str;
      default = "cgit";
      description = mdDoc ''
      Group account under which the webserver for cgit runs
      ''; 
    };

    
    cgitPackage = mkOption {
      default = pkgs.cgit;
      type = types.package;
      description = mdDoc ''
      The package to use for cgit
      '';
    };

    cgitConfig = mkOption {
      default = ''
      '';
      type = types.str;
      description = mdDoc ''
      The configuration to pass to cgit
      '';
    };

    gitRoot = mkOption {
      default = "/srv/git";
      type = types.str;
      description = mdDoc ''
      Where to look for git repos
      '';
    }

    port = mkOption {
      default = 80;
      type = types.int;
      description = mdDoc ''
      The port on which the webserver listens
      '';
    };

    logo = mkOption {
      default = "";
      type = types.str;
      description = mdDoc ''
      The path to the logo file, if empty, cgit default is used
      '';
    };
  };

  config = mkIf cfg.enable {

    systemd.packages = [ pkgs.cgit-server cfg.cgitPackage ];

    systemd.services.cgit = {
      
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = toString cfg.port;
        CGIT_DIR = "${cfg.cgitPackage}/cgit/";
        CGIT_CONFIG = "${cgitConfigFile}";
        LOGO = "${cfg.logo}";
      };
      
      serviceConfig = {
        ExecStart = ''
        ${pkgs.cgit-server}/bin/cgit-server
        '';

        User = cfg.user;
        Group = cfg.group;

        PrivateTmp = "yes";
        ProtectSystem = "full";
      };

    };

    users.users = optionalAttrs (cfg.user == "cgit") {
      cgit = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.group == "cgit") {
      cgit = {};
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };

}