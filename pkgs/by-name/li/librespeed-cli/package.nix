{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "librespeed-cli";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "librespeed";
    repo = "speedtest-cli";
    tag = "v${version}";
    hash = "sha256-LFGlKYWUaHi/byoRPD6zsdr0U5r0zWxxRa2NJNB2yb8=";
  };

  vendorHash = "sha256-psZyyySpY06J+ji+9uHUtX7Ks1hzZC3zINszYP75NfQ=";

  # Tests have additional requirements
  doCheck = false;

  meta = with lib; {
    description = "Command line client for LibreSpeed";
    homepage = "https://github.com/librespeed/speedtest-cli";
    changelog = "https://github.com/librespeed/speedtest-cli/releases/tag/${src.tag}";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ fab ];
    mainProgram = "speedtest-cli";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
