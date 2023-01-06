{
  autoPatchelfHook,
  fetchzip,
  lib,
  libxcb,
  makeDesktopItem,
  makeWrapper,
  mkDerivation,
  qt5,
}: let
  pname = "the-dark-aid";
  version = "15_alpha";
  qtVersion = "5.12";
  executable = "thedarkaid";

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "The Dark Aid ${version} QT ${qtVersion}";
    exec = executable;
    categories = ["Game" "RolePlaying"];
  };

  buildInputs = [
    libxcb
    qt5.qtbase
  ];
in
  mkDerivation {
    inherit pname version;

    src = fetchzip {
      url = "http://dsachargen.de/dev/thedarkaid_${version}_linux_qt${qtVersion}.tar.gz";
      hash = "sha256-/S80Gs5G/g6xVqjA7F3CCsxKWQMBhRqYr2e1RQ9ViDc=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      qt5.wrapQtAppsHook
    ];

    qtWrapperArgs = [
      ''--prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"''
      "--set-default QT_QPA_PLATFORM xcb"
    ];

    installPhase = ''
      runHook preInstall

      mkdir --parents "$out/bin"
      install --mode=755 "$src/${executable}" "$out/bin/"

      cp --no-preserve=mode --recursive "$src/lib" "$out/bin/"
      rm "$out/bin/lib/${executable}"

      cp --no-preserve=mode --recursive "${desktopItem}/share" "$out/"

      runHook postInstall
    '';

    meta = {
      description = "The Dark Eye 5 character creator";
      homepage = "http://dsachargen.de/";
      downloadPage = "https://www.ulisses-ebooks.de/product/309175/The-Dark-Aid";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      license = lib.licenses.unfree;
      maintainers = [lib.maintainers.l0b0];
      platforms = lib.platforms.linux;
    };
  }
