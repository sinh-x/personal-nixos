{
  boot.kernelParams = [ "snd-intel-dspcfg.dsp_driver=1" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
