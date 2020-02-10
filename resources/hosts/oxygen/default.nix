{
  imports = [
    ./../..
  ];

  config.resources = {
    btrfs.isSSD = false;
    btrfs.uuid = "343fa7d4-d8a6-43c2-88c2-e8c0531dfe2e";

    base16.theme = "onedark";
    graphics.enable = false;
  };
}
