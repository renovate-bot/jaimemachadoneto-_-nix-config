# default.nix
{ lib
, writeShellApplication
, bash
, netcat
}:
(writeShellApplication {
  name = "listener-code";
  runtimeInputs = [ bash netcat ];
  text = builtins.readFile ./listener-code.bash;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
