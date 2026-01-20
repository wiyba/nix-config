{ lib, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "uas"
    "sd_mod"
    "usbhid"
    "xe"
    "i915"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "thinkpad_acpi"
    "xe"
    "snd_sof_pci_intel_mtl"
    "iwlwifi"
    "btusb"
    "qmi_wwan"
    "cdc_wdm"
    "option"
    "uvcvideo"
    "hid_sensor_hub"
  ];
  boot.kernelParams = [ "acpi_backlight=native" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}
