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

  # 启用实验性特性（flakes 等）
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.accept-flake-config = true; # 自动接受 flake 的 nixConfig
  nix.channel.enable = false; # 关闭 channel，避免和 flakes 混用

  # 时区设置
  time.timeZone = "Asia/Shanghai"; # 设置时区为上海

  # 使用国内源
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=5"
    "https://cache.nixos.org/"
  ];

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


  # 系统基础软件包
  environment.systemPackages = with pkgs; [
    vim 
    git
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


  # 系统状态版本
  system.stateVersion = "25.11";

}