
{
  inputs,
  pkgs,
  libs,
  config,
  ...
}: {
  
  home.packages = with pkgs; [
    neovim
  ];
}
