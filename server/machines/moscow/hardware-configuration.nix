# NOTE: placeholder modelled on relay (qemu/KVM guest). After `nixos-infect`
# on Selectel, REPLACE this file with the generated /etc/nixos/hardware-configuration.nix
# from the box (verify root device — Selectel may use /dev/vda1 or /dev/sda1).
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
}
