{...}: {
  exposeKey = pkgs: user: key:
    pkgs.writeShellScript "expose-${key}.sh" ''
      chmod 0400 "${key}"
      chown ${user}:${user} "${key}"
    '';

  hideKey = pkgs: user: key:
    pkgs.writeShellScript "hide-${key}.sh" ''
      chmod 0000 "${key}"
      chown ${user}:${user} "${key}"
    '';
}
