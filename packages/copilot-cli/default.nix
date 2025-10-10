{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs)
    lib
    stdenv
    buildNpmPackage
    makeWrapper
    nodejs_22
    fetchurl;

  version = "0.0.337";
  supportedSystem = "x86_64-linux";
  npmName = "@github/copilot";

  npmNameEscaped = lib.replaceStrings [ "@" ] [ "%40" ] npmName;

  upstreamTarball = fetchurl {
    url = "https://registry.npmjs.org/${npmNameEscaped}/-/copilot-${version}.tgz";
    hash = "sha256-5Mm2IL2kIPoROR/1imKy2qneOFbyMVAYhzTWpodCr4Y=";
  };

  src = pkgs.runCommand "copilot-src-${version}"
    {
      buildInputs = [ pkgs.gnutar pkgs.gzip ];
    } ''
    mkdir source
    tar -xzf ${upstreamTarball} -C source
    cp ${./package-lock.json} source/package/package-lock.json
    mkdir -p $out
    cp -r source/package/. $out
  '';

in
assert stdenv.hostPlatform.system == supportedSystem;
buildNpmPackage {
  pname = "copilot";
  inherit version src;

  nodejs = nodejs_22;
  npmFlags = [ "--loglevel" "error" ];
  nativeBuildInputs = [ makeWrapper ];
  dontNpmBuild = true;

  npmDepsHash = "sha256-KIFUotHevVgk7ZlJu1xLHYdKWA1tYHfEK8cyME4Xt/g=";

  postInstall = ''
    wrapProgram "$out/bin/copilot" \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 ]}
  '';

  meta = with lib; {
    description = "GitHub Copilot CLI";
    homepage = "https://github.com/github/copilot-cli";
    license = licenses.mit;
    maintainers = [ ];
    platforms = [ supportedSystem ];
  };
}
