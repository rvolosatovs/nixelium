{
  imports = [
    ./../..
  ];

  config.resources = {
    btrfs.isSSD = true;
    btrfs.uuid = "95f03ff6-b94c-4a7b-b122-9ef73507e26b";

    base16.theme = "tomorrow-night";
  };
}
