{ buildGoModule }:

buildGoModule {
    pname = "cgit-server";
    version = "0.1";

    src = ./.;
    vendorSha256 = null;
}