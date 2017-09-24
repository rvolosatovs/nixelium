{...}:
{
  hardware = {
    trackpoint.emulateWheel = true;
  };

  services = {
      libinput = {
        scrollButton = 1;
        middleEmulation = false;
      };
  }
}
