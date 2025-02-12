# https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/
# https://github.com/Juggeli/nixos-config/blob/734f2b955e4fd160ba42d4bde51e7f2077b1dde0/systems/x86_64-linux/noel/disk-config.nix
{
  lib,
  config,
  clan-core,
  ...
}: let
  suffix = config.clan.core.vars.generators.disk-id.files.diskId.value;
  mirrorBoot = idx: {
    # suffix is to prevent disk name collisions
    name = idx + suffix;
    type = "disk";
    device = "/dev/disk/by-id/${idx}"; # replace with your disk id (lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT)
    content = {
      type = "gpt";
      partitions = {
        "ESP" = lib.mkIf (idx == "nvme-eui.e8238fa6bf530001001b448b467ba735") {
          label = "boot";
          name = "ESP";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "defaults"
              "nofail"
            ];
          };
        };

        luks = {
          size = "100%";
          label = "luks";
          content = {
            type = "luks";
            name = "cryptroot";
            extraOpenArgs = [
              "--allow-discards"
              "--perf-no_read_workqueue"
              "--perf-no_write_workqueue"
            ];
            # if you want to use the key for interactive login be sure there is no trailing newline
            # for example use `echo -n "password" > /tmp/secret.key`
            passwordFile = "/tmp/secret.key"; # Interactive
            # or file based
            #settings.keyFile = "/tmp/secret.key";
            #additionalKeyFiles = ["/tmp/additionalSecret.key"];
            # FIDO based
            # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
            # settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
            content = {
              type = "btrfs";
              extraArgs = ["-L" "nixos" "-f"];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/root-blank" = {
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/home" = {
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/home/active" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/home/snapshots" = {
                  mountpoint = "/home/.snapshots";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                };
                "/persist" = {
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist/active" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist/snapshots" = {
                  mountpoint = "/persist/.snapshots";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = 32 * 1024;
                };
              };
            };
          };
        };
      };
    };
  };
in {
  imports = [
    clan-core.clanModules.disk-id
  ];

  config = {
    boot.loader.systemd-boot.enable = true;

    disko.devices = {
      disk = {
        x = mirrorBoot "nvme-eui.e8238fa6bf530001001b448b467ba735"; # replace with your disk id (lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT)
      };
    };

    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
  };
}
