{
  inputs,
  ...
}:
_final: prev: {
  inherit (inputs.fcitx5-lotus.packages.${prev.stdenv.hostPlatform.system}) fcitx5-lotus;
}
