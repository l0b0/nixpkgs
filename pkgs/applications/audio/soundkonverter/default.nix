# currently needs to be installed into an environment and needs a `kbuildsycoca5` run afterwards for plugin discovery
{
  mkDerivation,
  fetchFromGitHub,
  fetchpatch,
  lib,
  makeWrapper,
  cmake,
  extra-cmake-modules,
  pkg-config,
  libkcddb,
  kconfig,
  kconfigwidgets,
  ki18n,
  kdelibs4support,
  kio,
  solid,
  kwidgetsaddons,
  kxmlgui,
  qtbase,
  phonon,
  taglib_1,
  # optional backends
  withCD ? true,
  cdparanoia,
  withFlac ? true,
  flac,
  withMidi ? true,
  fluidsynth,
  timidity,
  withSpeex ? false,
  speex,
  withVorbis ? true,
  vorbis-tools,
  vorbisgain,
  withMp3 ? true,
  lame,
  mp3gain,
  withAac ? true,
  faad2,
  aacgain,
  withUnfreeAac ? false,
  faac,
  withFfmpeg ? true,
  ffmpeg-full,
  withMplayer ? false,
  mplayer,
  withSox ? true,
  sox,
  withOpus ? true,
  opusTools,
  withTwolame ? false,
  twolame,
  withApe ? false,
  monkeysAudio,
  withWavpack ? false,
  wavpack,
}:

assert withAac -> withFfmpeg || withUnfreeAac;
assert withUnfreeAac -> withAac;

let
  runtimeDeps =
    [ ]
    ++ lib.optional withCD cdparanoia
    ++ lib.optional withFlac flac
    ++ lib.optional withSpeex speex
    ++ lib.optional withFfmpeg ffmpeg-full
    ++ lib.optional withMplayer mplayer
    ++ lib.optional withSox sox
    ++ lib.optional withOpus opusTools
    ++ lib.optional withTwolame twolame
    ++ lib.optional withApe monkeysAudio
    ++ lib.optional withWavpack wavpack
    ++ lib.optional withUnfreeAac faac
    ++ lib.optionals withMidi [
      fluidsynth
      timidity
    ]
    ++ lib.optionals withVorbis [
      vorbis-tools
      vorbisgain
    ]
    ++ lib.optionals withMp3 [
      lame
      mp3gain
    ]
    ++ lib.optionals withAac [
      faad2
      aacgain
    ];

in
mkDerivation rec {
  pname = "soundkonverter";
  version = "3.0.1";
  src = fetchFromGitHub {
    owner = "dfaust";
    repo = "soundkonverter";
    rev = "v" + version;
    sha256 = "1g2khdsjmsi4zzynkq8chd11cbdhjzmi37r9jhpal0b730nq9x7l";
  };
  patches = [
    # already merged into master, so it can go during the next release
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/dfaust/soundkonverter/pull/87.patch";
      sha256 = "sha256-XIpD4ZMTZVcu+F27OtpRy51H+uQgpd5l22IZ6XsD64w=";
      name = "soundkonverter_taglib.patch";
      stripLen = 1;
    })
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    kdelibs4support
    makeWrapper
  ];
  propagatedBuildInputs = [
    libkcddb
    kconfig
    kconfigwidgets
    ki18n
    kdelibs4support
    kio
    solid
    kwidgetsaddons
    kxmlgui
    qtbase
    phonon
  ];
  buildInputs = [ taglib_1 ] ++ runtimeDeps;
  # encoder plugins go to ${out}/lib so they're found by kbuildsycoca5
  cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=$out" ];
  sourceRoot = "${src.name}/src";
  # add runt-time deps to PATH
  postInstall = ''
    wrapProgram $out/bin/soundkonverter --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';
  meta = {
    homepage = "https://github.com/dfaust/soundkonverter";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.schmittlauch ];
    description = "Audio file converter, CD ripper and Replay Gain tool";
    mainProgram = "soundkonverter";
    longDescription = ''
      soundKonverter is a frontend to various audio converters.

      The key features are:
      - Audio file conversion
      - Replay Gain calculation
      - CD ripping

      soundKonverter supports reading and writing tags and covers for many formats, so they are preserved when converting files.

      It is extendable by plugins and supports many backends including:

      - Audio file conversion
        Backends: faac, faad, ffmpeg, flac, lame, mplayer, neroaac, timidity, fluidsynth, vorbistools, opustools, sox, twolame,
        flake, mac, shorten, wavpack and speex
        Formats: ogg vorbis, mp3, flac, wma, aac, ac3, opus, alac, mp2, als, amr nb, amr wb, ape, speex, m4a, mp1, musepack shorten,
        tta, wavpack, ra, midi, mod, 3gp, rm, avi, mkv, ogv, mpeg, mov, mp4, flv, wmv and rv

      - Replay Gain calculation
        Backends: aacgain, metaflac, mp3gain, vorbisgain, wvgain, mpcgain
        Formats: aac, mp3, flac, ogg vorbis, wavpack, musepack

      - CD ripping
        Backends: cdparanoia
    '';
  };
}
