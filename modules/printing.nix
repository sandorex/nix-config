{...}:

{
  services.printing.enable = true;
  services.printing.drivers = with stable; [
    # Xerox 3010
    foo2zjs
  ];
}
