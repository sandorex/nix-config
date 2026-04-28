path:

# stores all references to secrets that are in a different repository

let
  secretsRoot = "${path}/secrets";
  found = builtins.pathExists secretsRoot;

  get = if found then
      (x: builtins.readFile "${secretsRoot}/${x}")
    else
      (x: {});
  getJSON = if found then
      (x: builtins.fromJSON (get x))
    else
      (x: {});
in

{
  # format: { ssid = "password"; }
  wifi = getJSON "wifi.json";
}
