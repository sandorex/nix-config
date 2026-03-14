path:

# store all references to secrets that are in a different repository

let
  secretsRoot = "${path}/secrets";

  get = x: builtins.readFile "${secretsRoot}/${x}";
  getJSON = x: builtins.fromJSON (get x);

  secrets = {
    # format: { ssid = "password"; }
    wifi = getJSON "wifi.json";
  };

  found = builtins.pathExists secretsRoot;
in
{
  inherit found;

  valOr = if found (x: y: x) else (x: y: y);
} // (if found then secrets else {})
