{ pkgs, ... }:
{
  # 语言和国际化
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
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

  # 统一设置输入法环境变量，覆盖 GTK/Qt/XWayland 常见场景
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    INPUT_METHOD = "fcitx";
  };

  # 使用 Home Manager 声明式管理 Fcitx5 配置，避免手动改动在重建后丢失。
  # 热键字段参考 Fcitx5 官方配置格式（[Hotkey] 与 [Hotkey/*] 段）。
  home-manager.users.kd.xdg.configFile = {
    "fcitx5/config".text = ''
      [Hotkey]
      EnumerateWithTriggerKeys=True
      EnumerateForwardKeys=
      EnumerateBackwardKeys=
      EnumerateSkipFirst=False
      ModifierOnlyKeyTimeout=250

      [Hotkey/TriggerKeys]
      0=Control+space

      [Hotkey/AltTriggerKeys]
      0=Shift_L

      [Hotkey/EnumerateGroupForwardKeys]
      0=Super+space

      [Hotkey/EnumerateGroupBackwardKeys]
      0=Shift+Super+space

      [Hotkey/PrevCandidate]
      0=Shift+Tab

      [Hotkey/NextCandidate]
      0=Tab

      [Behavior]
      ActiveByDefault=False
      resetStateWhenFocusIn=No
      ShareInputState=No
      PreeditEnabledByDefault=True
      ShowInputMethodInformation=True
      showInputMethodInformationWhenFocusIn=False
      CompactInputMethodInformation=True
      ShowFirstInputMethodInformation=True
      DefaultPageSize=5
      OverrideXkbOption=False
      CustomXkbOption=
      EnabledAddons=
      DisabledAddons=
      PreloadInputMethod=True
      AllowInputMethodForPassword=False
      ShowPreeditForPassword=False
      AutoSavePeriod=30
    '';

    "fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=keyboard-us

      [Groups/0/Items/0]
      Name=pinyin
      Layout=

      [Groups/0/Items/1]
      Name=keyboard-us
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  # 输入法列表改为使用 fcitx5-configtool 图形界面手动管理

  # 字体：通用 + 中文 + Emoji
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono
  ];
}