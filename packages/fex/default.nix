# default.nix
{ lib
, writeShellApplication
, fzf
, bat
}:
(writeShellApplication {
  name = "fex";
  runtimeInputs = [ fzf bat ];
  text = builtins.readFile ./fex.sh;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
