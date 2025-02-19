{
  pkgs,
  wrapFirefox,
  namespace,
}:
wrapFirefox pkgs.${namespace}.zen-browser-unwrapped {
  pname = "zen-browser";
  libName = "zen";
}
