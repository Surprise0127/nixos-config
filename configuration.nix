# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./niri.nix
      ./fcitx5.nix
      ./nvidia.nix
    ];

  # EFI 引导设置
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # 缩短引导菜单等待时间，减少开机到会话的可感知延迟
  boot.loader.timeout = 1;
  
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

  users.groups.kd = { };
  users.users.kd = {
    isNormalUser = true;
    group = "kd";
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

  # 系统基础软件包
  environment.systemPackages = with pkgs; [
    vim 
    git
    alacritty
    fuzzel
    firefox
    vscode
    # niri 官方文档中的 Xwayland 相关组件，避免会话启动时查找失败
    xwayland-satellite
    qt6Packages.fcitx5-configtool
  ];


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

  # Home Manager 配置
  home-manager.users.kd = {
    home.stateVersion = "25.11";
  };

  # 电源管理设置
  services.power-profiles-daemon.enable = true; # 启用电源配置守护程序，提供性能和节能模式
  services.upower.enable = true; # 启用电源管理服务，监控电池状态和电源事件

  # 系统状态版本
  system.stateVersion = "25.11";

}