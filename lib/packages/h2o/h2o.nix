{ lib, stdenv, fetchFromGitHub
, pkg-config, cmake, ninja
, openssl, libuv, zlib
, perl
}:

stdenv.mkDerivation rec {
  pname   = "h2o";
  version = "trunk-2023-08-07";

  src = fetchFromGitHub {
    owner  = "h2o";
    repo   = "h2o";
    rev    = "071ce9026438d8020bc7ed5c0ef6fa68095e1041";
    sha256 = "pVtovX9oq78cjxvKMP723gZvHWtZazSR1kc2Qn5HggU=";
  };

  patches = [ ./0001-Patch.patch ];

  outputs = [ "out" "man" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja ];
  buildInputs = [ openssl libuv zlib perl ];

  meta = with lib; {
    description = "Optimized HTTP/1 and HTTP/2 server";
    homepage    = "https://h2o.examp1e.net";
    license     = licenses.mit;
    maintainers = with maintainers; [ thoughtpolice ];
    platforms   = platforms.linux;
  };
}