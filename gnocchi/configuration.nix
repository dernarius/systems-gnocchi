# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.initrd.kernelModules = [ "i915" ];

  networking.hostName = "gnocchi";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vilnius";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  users.users.stk = {
    isNormalUser = true;
    description = "Stanislovas";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" "plugdev" "dialout" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  services.pipewire.enable = true;
  services.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    # system utils
    docker-compose
    duplicity
    fastfetch
    imagemagick
    light
    ncdu
    powertop
    udiskie
    udisks
    unzip
    usbutils
    v4l-utils
    v4l2-relayd
    
    # sway/wayland utils
    grim
    hyprlock
    i3status
    mako
    rofi
    slurp
    swayidle
    wl-clipboard
    wshowkeys

    # audio
    alsa-tools
    alsa-utils
    pa-notify
    pamixer
    pasystray
    pavucontrol
    
    # utils
    curl
    fd
    gnumake
    jq
    just
    nomacs
    playerctl
    tesseract
    tree
    wget

    # applications
    abcde
    acpica-tools
    alacritty
    alacritty-theme
    calibre
    deluge
    discord
    freecad
    git
    inkscape
    kicad
    obs-studio
    onlyoffice-desktopeditors
    pinentry-all
    postman
    trayscale
    thunderbird
    vlc

    # languages
    bun
    clang
    gcc
    lua-language-server
    nixd
    python312
    python312Packages.pip
    rustup
    stylua
    uv
    zig
    zsh
    ty

    # games
    lunar-client
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.monofur
    corefonts
    vista-fonts
  ];

  programs.zsh = {
    enable = true;
  };

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
  };

  programs.wshowkeys.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  systemd.timers."backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2 hours";
      OnUnitActiveSec = "2 hours";
      Unit = "incremental-backup.service";
    };
  };

  systemd.services."incremental-backup" = {
    script = ''
      ${pkgs.duplicity}/bin/duplicity incremental \
        --encrypt-sign-key F1D15517 \
        --exclude /home/stk/.cache \
        --exclude /home/stk/.mozilla \
        --exclude /home/stk/.steam \
        --exclude /home/stk/.bun \
        --exclude /home/stk/.local/share/Steam \
        --exclude /home/stk/Games \
        /home/stk \
        scp://girlboss//mnt/newtent/stk/gnocchi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "stk";
    };
    environment = {
      PASSPHRASE = "";
    };
  };

  systemd.services."full-backup" = {
    script = ''
      ${pkgs.duplicity}/bin/duplicity full \
        --encrypt-sign-key F1D15517 \
        --exclude /home/stk/.cache \
        --exclude /home/stk/.mozilla \
        --exclude /home/stk/.steam \
        --exclude /home/stk/.bun \
        --exclude /home/stk/.local/share/Steam \
        --exclude /home/stk/Games \
        /home/stk \
        scp://girlboss//mnt/newtent/stk/gnocchi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "stk";
    };
    environment = {
      PASSPHRASE = "";
    };
  };

  services.blueman.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.avahi.enable = true;

  services.gvfs.enable = true;

  services.udisks2.enable = true;

  services.tumbler.enable = true;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  services.keyd = {
    enable = true;
    keyboards = {
      # The name is just the name of the configuration file, it does not really matter
      default = {
        ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
        # Everything but the ID section:
        settings = {
          # The main layer, if you choose to declare it in Nix
          main = {
            capslock = "overload(control, esc)"; # you might need to also enclose the key in quotes if it contains non-alphabetical symbols
          };
          otherlayer = {};
        };
        extraConfig = ''
          # put here any extra-config, e.g. you can copy/paste here directly a configuration, just remove the ids part
        '';
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.swayfx}/bin/sway";
        user = "stk";
      };
      default_session = initial_session;
    };
  };

  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    6969 8000 8080  # development stuff
  ];

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
