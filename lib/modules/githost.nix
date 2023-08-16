{ config, pkgs, lib, ...}:

with lib;

let

  cfg = config.services.githost;


in {

    options.services.githost = {
        enable = mkEnableOption "githost"; 

        user = mkOption {
            type = types.str;
            default = "git";
            description = mdDoc ''
            User for ssh git actions. 
            Needs to be present if user != git.
            '';
        };

        group = mkOption {
            type = types.str;
            default = "git";
            description = mdDoc ''
            Group for ssh git actions. 
            Needs to be present if group != git.
            '';
        };

        gitPackage = mkOption {
            type = types.package;
            default = pkgs.git;
            description = mdDoc ''
            Package to use for git
            '';
        };

        authorizedKeys = mkOption {
            type = types.listOf types.str;
            default = [];
            description = mdDoc ''
            A list of ssh keys that can push to this remote
            '';
        };

        gitRoot = mkOption {
            type = types.str;
            default = "/srv/git";
            description = mdDoc ''
            Filesystem location to use for git repos
            '';
        };
    };

    config = mkIf cfg.enable {

        users.users = optionalAttrs (cfg.user == "git") {
            git = {
                group = cfg.group;
                isSystemUser = true;
                home = cfg.gitRoot;
                createHome = true;
                shell = "${cfg.gitPackage}/bin/git-shell";
                openssh.authorizedKeys.keys = cfg.authorizedKeys;
            };
        };

        users.groups = optionalAttrs (cfg.group == "git") {
            git = {};
        };

        systemd.tmpfiles.rules = [
            ''L+ /srv/git/git-shell-commands 1777 git git - ${pkgs.githost-scripts}''
        ];
    };
}