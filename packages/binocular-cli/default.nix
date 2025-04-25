{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "binocular-cli";
  version = "main";

  src = fetchFromGitHub {
    owner = "jpcrs";
    repo = pname;
    rev = version;
    hash = "sha256-e0LGj86FgWgermTXF7V19Ddi7Axlu4sMaB+Z2kf+bJc=";
  };

  cargoHash = "sha256-E0hLhY9TRlRLcwQ3T2Zni9OMGr5EsbqklFPF/4QZwu0=";

  meta = {
    description = "Binocular-cli tool";
    homepage = "https://github.com/jpcrs/binocular-cli";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
