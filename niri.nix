{ config, pkgs, ... }:
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
  home-manager.users.drfoobar = {
    home.stateVersion = "25.11";

    programs.niri = {
      enable = true;
      settings = {
        spawn-at-startup = [
          {
            command = [ "noctalia-shell" ];
          }
        ];
      };
    };
  };
}