{ config, lib, ... }:
{
  # NVIDIA 闭源驱动需要允许 unfree 包
  nixpkgs.config.allowUnfree = true;

  # 加载 NVIDIA 驱动
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  # Intel iGPU + NVIDIA dGPU（如 i5-1135G7 + MX450）推荐使用 PRIME offload
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # 常见笔记本总线号，必要时可在其他模块覆盖
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:1:0:0";
    };
  };
}