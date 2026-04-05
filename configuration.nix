# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # EFI 引导设置
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # 主机名
  networking.hostName = "nixos"; # 设置主机名

  # 网络管理
  networking.networkmanager.enable = true; # 启用 NetworkManager

  # 用户设置（Home Manager 目标用户）
  users.groups.drfoobar = { };
  users.users.drfoobar = {
    isNormalUser = true;
    group = "drfoobar";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # 启用实验性特性（flakes 等）
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.accept-flake-config = true; # 自动接受 flake 的 nixConfig
  nix.channel.enable = false; # 关闭 channel，避免和 flakes 混用

  # 时区设置
  time.timeZone = "Asia/Shanghai"; # 设置时区为上海

  # 使用国内源加速 Nix 包管理器  
  nix.settings = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
      # 国内镜像偶发 DNS/连接超时，按需手动开启：
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ]; # 添加 noctalia.cachix.org 的公钥，允许从该源下载包
};

  # 语言和国际化
  i18n.defaultLocale = "en_US.UTF-8"; # 设置默认语言为英语
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8"; # 设置时间格式为中文
  };

  # 输入法：启用 Fcitx5（中文）
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };

  # 字体：通用 + 中文 + Emoji
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono
  ];


  # 系统基础软件包
  environment.systemPackages = with pkgs; [
    vim 
    git
    alacritty
    fuzzel
    firefox
    qt6Packages.fcitx5-configtool
  ];

  # 启用 Niri（Wayland 合成器）
  programs.niri.enable = true;
  programs.niri.useNautilus = false; # 用 GTK 文件选择器，避免强依赖 Nautilus

  # 使用 greetd 作为登录管理器，并启动 Niri 会话
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  # 自定义用户
  users.users.kd = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };


  # SSH 服务设置
  services.openssh = {
    enable = true; # 启用 SSH 服务
    settings = {
      PasswordAuthentication = true;   # 允许密码登录
      PermitRootLogin = "yes";         # 允许 root 登录
    };
  };

  # 音频服务设置
  services.pulseaudio.enable = false; # 禁用 PulseAudio
  security.rtkit.enable = true; # 启用实时权限管理器，提升音频性能
  services.pipewire = { 
    enable = true; # 启用 PipeWire
    alsa.enable = true; # 启用 ALSA 支持
    alsa.support32Bit = true; # 启用 32 位 ALSA 支持
    pulse.enable = true; # 启用 PulseAudio 兼容层
  };

  # 蓝牙支持设置
  hardware.bluetooth.enable = true; # 启用蓝牙支持

  # 电源管理设置
  services.power-profiles-daemon.enable = true; # 启用电源配置守护程序，提供性能和节能模式
  services.upower.enable = true; # 启用电源管理服务，监控电池状态和电源事件

  # 系统状态版本
  system.stateVersion = "25.11";

}