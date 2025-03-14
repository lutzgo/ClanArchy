{inputs, ...}: {
  imports = [
    # contains your disk format and partitioning configuration.
    ./disko.nix
    #./disko.nix
    #./initrd.nix
    # this file is shared among all machines
    ../../modules/shared.nix
    # enables GNOME desktop (optional)
    ../../modules/gnome.nix
  ];

  # This is your user login name.
  users.users.user.name = "lgo";

  # Set this for clan commands use ssh i.e. `clan machines update`
  # If you change the hostname, you need to update this line to root@<new-hostname>
  # This only works however if you have avahi running on your admin machine else use IP
  clan.core.networking.targetHost = "root@flores";

  # You can get your disk id by running the following command on the installer:
  # Replace <IP> with the IP of the installer printed on the screen or by running the `ip addr` command.
  # ssh root@<IP> lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b467ba735";

  # IMPORTANT! Add your SSH key here
  # e.g. > cat ~/.ssh/id_ed25519.pub
  users.users.root.openssh.authorizedKeys.keys = [
    ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXmNe7FQqlHTMVbTCq+GJY52gYq5IadHNwh2ifzsy5H jon
    ''
  ];

  # Zerotier needs one controller to accept new nodes. Once accepted
  # the controller can be offline and routing still works.
  #clan.core.networking.zerotier.networkId = builtins.readFile (config.clan.core.settings.directory + "/machines/jon/facts/zerotier-network-id");
}
