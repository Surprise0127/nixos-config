{ config, pkgs, inputs, lib, ... }:
{
  # niri-flake 文档说明 GNOME portal 是 niri 下屏幕共享所需后端。
  # 显式收敛后端选择，减少会话初始化时额外 portal 后端启动。
  xdg.portal = {
    enable = true;
    extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-gnome ];
    config = lib.mkForce {
      common.default = [ "gnome" ];
    };
  };

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
      settings = {
        # 如果不显式设置 binds，niri-flake 会生成空绑定，导致快捷键全部失效。
        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

          "Mod+T".action.spawn = [ "alacritty" ];
          "Mod+Return".action.spawn = [ "alacritty" ];
          "Mod+D".action.spawn = [ "fuzzel" ];
          "Mod+Q".action.close-window = [ ];

          "Mod+Left".action.focus-column-left = [ ];
          "Mod+Down".action.focus-window-down = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+H".action.focus-column-left = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+L".action.focus-column-right = [ ];

          "Mod+Ctrl+Left".action.move-column-left = [ ];
          "Mod+Ctrl+Down".action.move-window-down = [ ];
          "Mod+Ctrl+Up".action.move-window-up = [ ];
          "Mod+Ctrl+Right".action.move-column-right = [ ];

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
        };

        spawn-at-startup = [
          {
            command = [ "noctalia-shell" ];
          }
        ];
      };
    };
  };
}