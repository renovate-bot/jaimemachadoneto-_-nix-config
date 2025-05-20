# default.nix
{ lib
, writeShellApplication
, bash
}:
(writeShellApplication {
  name = "rcode";
  runtimeInputs = [ bash ];
  text = builtins.readFile ./rcode.bash;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
