{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "jmntool";
  version = "unstable-2025-03-20"; # Using date-based versioning for unstable builds

  format = "pyproject"; # Specify that we're using pyproject.toml

  src = fetchFromGitHub {
    owner = "jaimemachadoneto";
    repo = "tools";
    rev = "v0.0.2"; # Always fetch the latest code from main branch
    sha256 = "sha256-VR8ovTl3+17f2Dj83EEnKTA2cTfBkvLU8dZFZqgtWwg="; # Will fail with the correct hash on first build
  };

  # Add flit_core as a build input for the build backend
  nativeBuildInputs = with python3Packages; [
    flit-core
  ];

  # For any dependencies not correctly extracted from pyproject.toml
  propagatedBuildInputs = with python3Packages; [
    # Add any missing dependencies here
    GitPython
    click
  ];

  # Testing dependencies
  checkInputs = with python3Packages; [
    pytest
  ];

  # Adjust if you have custom test needs
  checkPhase = ''
    pytest
  '';

  # Set to false initially to allow building despite hash mismatch
  doCheck = false;

  meta = with lib; {
    description = "A Python CLI tool"; # Update with actual description
    homepage = "https://github.com/jaimemachadoneto/tools";
    license = licenses.mit; # Update with your project's actual license
    maintainers = with maintainers; [ "jaimemachadoneto" ];
  };
}
