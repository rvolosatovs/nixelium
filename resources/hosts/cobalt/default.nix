{
  imports = [
    ./../..
  ];

  config.resources = {
    btrfs.isSSD = true;
    btrfs.uuid = "23996086-ccb9-4e94-8ece-e45fe6f47718";

    base16.theme = "tomorrow-night";
    graphics.enable = true;
  };
}
