{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
# v6.13.7 handles qBittorrent HTTP 204 bypass-auth responses correctly
# (v6.13.6 treats them as failures).
buildNpmPackage rec {
  pname = "cross-seed";
  version = "6.13.7";

  src = fetchFromGitHub {
    owner = "cross-seed";
    repo = "cross-seed";
    tag = "v${version}";
    hash = "sha256-+7A4UGIY75hvF0JvtIr6nGNdXkUE0XV9TFpEQz9OW+Y=";
  };

  npmDepsHash = "sha256-HoIiO7cj4JNY+sJEuH1v0AgagDuBTySJaoVo/4SsfIc=";

  meta = with lib; {
    description = "Fully-automatic torrent cross-seeding with Torznab";
    homepage = "https://cross-seed.org";
    license = licenses.asl20;
    mainProgram = "cross-seed";
    maintainers = [maintainers.mkez];
  };
}
