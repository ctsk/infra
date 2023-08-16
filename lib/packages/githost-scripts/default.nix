{ lib, python3, stdenv
}:

stdenv.mkDerivation rec {
  pname = "githost-scripts";
  version = "v0.1";

  src = ./.;

  outputs = [ "out" ];

  buildInputs = [ python3 ];

  installPhase = ''
  mkdir $out
  cp $src/create-repo $out
  '';

  meta = with lib; {
    description = "scripts for git servers";
    platforms = platforms.linux;
  };
}