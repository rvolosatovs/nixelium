#{ config, device ? "/dev/sda2", name ? "luksroot", ...}:
# 
#{
#  config.boot.initrd.luks.devices = [
#    {
#      name = name;
#      device = device
#      preLVM=true; 
#      allowDiscards=true;
#    }
#  ];
#}
# FIXME doesn't work
