{ config, pkgs, inputs, ... }:
{
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

  # Home Manager 用户级 Niri 配置：登录后自动拉起 Noctalia
  home-manager.users.kd = {
    home.stateVersion = "25.11";

    # 导入官方模块：Noctalia HM + niri-flake HM config
    imports = [
      inputs.noctalia.homeModules.default
      inputs.niri.homeModules.config
    ];

    programs.noctalia-shell = {
      enable = true;
      # 官方文档说明已不推荐 systemd startup，优先由合成器/自动启动拉起
      systemd.enable = false;
    };

    # Noctalia 官方推荐：由 Niri 的 spawn-at-startup 启动
    programs.niri = {
      # 让 niri-flake 的配置校验使用和系统一致的 niri 包
      package = config.programs.niri.package;
      settings.spawn-at-startup = [
        {
          command = [ "noctalia-shell" ];
        }
      ];
    };
  };
}