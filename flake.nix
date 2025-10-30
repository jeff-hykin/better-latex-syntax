{
    description = "Better Latex Syntax";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        nixpkgsWithNodejs18.url = "https://github.com/NixOS/nixpkgs/archive/a71323f68d4377d12c04a5410e214495ec598d4c.tar.gz";
        nixpkgsWithRuby.url = "https://github.com/NixOS/nixpkgs/archive/ebf88190cce9a092f9c7abe195548057a0273e51.tar.gz";
        home-manager.url = "github:nix-community/home-manager/release-25.05";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        xome.url = "github:jeff-hykin/xome";
        xome.inputs.nixpkgs.follows = "nixpkgs";
        xome.inputs.home-manager.follows = "home-manager";
    };
    outputs = { self, nixpkgs, nixpkgsWithNodejs18, nixpkgsWithRuby, xome, ... }:
        xome.superSimpleMakeHome { inherit nixpkgs; pure = true; } ({system, ...}:
            let
                setup = {
                    system = system;

                    # This is where you allow insecure/unfree packages
                    config = {
                        allowUnfree = true;
                        allowInsecure = true;
                        permittedInsecurePackages = [
                            "python-2.7.18.8"
                            "python-2.7.18.6"
                            "openssl-1.0.2u"
                        ];
                    };
                };
                pkgs = import nixpkgs setup;
                # pkgsWithPython38 = import nixpkgsWithPython38 setup;
                pkgsWithNodejs18 = import nixpkgsWithNodejs18 setup;
                pkgsWithRuby = import nixpkgsWithRuby setup;
            in
                {
                    # for home-manager examples, see: https://deepwiki.com/nix-community/home-manager/5-configuration-examples
                    # all home-manager options: https://nix-community.github.io/home-manager/options.xhtml
                    home.homeDirectory = "/tmp/virtual_homes/better-latex-syntax";
                    home.stateVersion = "25.05";
                    home.packages = [
                        # vital stuff
                        pkgs.coreutils-full
                        
                        # optional stuff
                        pkgs.bash
                        pkgs.gnugrep
                        pkgs.findutils
                        pkgs.wget
                        pkgs.curl
                        pkgs.unixtools.locale
                        pkgs.unixtools.more
                        pkgs.unixtools.ps
                        pkgs.unixtools.getopt
                        pkgs.unixtools.ifconfig
                        pkgs.unixtools.hostname
                        pkgs.unixtools.ping
                        pkgs.unixtools.hexdump
                        pkgs.unixtools.killall
                        pkgs.unixtools.mount
                        pkgs.unixtools.sysctl
                        pkgs.unixtools.top
                        pkgs.unixtools.umount
                        pkgs.git
                        
                        # project specific
                        pkgs.jq
                        pkgsWithNodejs18.nodejs
                        pkgs.python2
                        pkgs.cmake
                        pkgs.pkg-config
                        pkgs.libffi
                        pkgsWithRuby.ruby.devEnv # ruby 2.7.8
                        pkgsWithRuby.bundix
                        pkgsWithRuby.sqlite
                        pkgsWithRuby.libpcap
                        pkgsWithRuby.postgresql
                        pkgs.libxml2
                        pkgs.libxslt
                        pkgs.gnumake
                        pkgs.ncurses5
                        pkgs.openssh
                    ];
                    
                    programs = {
                        home-manager = {
                            enable = true;
                        };
                        zsh = {
                            enable = true;
                            enableCompletion = true;
                            autosuggestion.enable = true;
                            syntaxHighlighting.enable = true;
                            shellAliases.ll = "ls -la";
                            history.size = 100000;
                            # this is kinda like .zshrc
                            initContent = ''
                                # lots of things need "sh"
                                ln -s "$(which dash)" "$HOME/.local/bin/sh" 2>/dev/null
                                
                                # most people expect comments in their shell to to work
                                setopt interactivecomments
                                
                                #
                                # Ruby setup
                                #
                                export GEM_HOME="$HOME/gems.ignore/"
                                # if not setup yet, then setup ruby
                                if ! [ -d "$VAR" ]
                                then
                                    mkdir "$GEM_HOME" &>/dev/null
                                    bundix -l
                                    bundler install
                                fi
                                
                                # without this npm (from nix) will not keep a reliable cache (it'll be outside of the xome home)
                                export npm_config_cache="$HOME/.cache/npm"
                                
                                if ! [ -d "node_modules" ]
                                then
                                    printf "\n\nI don't see node modules, want me to install them (default=yes)? [y/n]\n";answer=""
                                    while true; do
                                        echo "$question"; read response
                                        case "$response" in
                                            [Yy]* ) answer='yes'; break;;
                                            [Nn]* ) answer='no'; break;;
                                            * ) echo "Please answer yes or no.";;
                                        esac
                                    done
                                    
                                    if [ "$answer" = 'yes' ]; then
                                        yarn install
                                    else
                                        echo "skipping"
                                    fi
                                fi
                                
                                # this enables some impure stuff like sudo, comment it out to get FULL purity
                                # export PATH="$PATH:/usr/bin/"
                                echo
                                echo "NOTE: if you want to use sudo/git/vim/etc (anything impure) do: sys <that command>"
                            '';
                        };
                        starship = {
                            enable = true;
                            enableZshIntegration = true;
                            settings = {
                                character = {
                                    success_symbol = "[∫](bold green)";
                                    error_symbol = "[∫](bold red)";
                                };
                            };
                        };
                    };
                }
        );
}