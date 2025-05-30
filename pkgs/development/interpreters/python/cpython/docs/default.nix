{
  stdenv,
  fetchurl,
  lib,
}:

let
  pythonDocs = {
    html = {
      recurseForDerivations = true;
      python27 = import ./2.7-html.nix {
        inherit stdenv fetchurl lib;
      };
      python310 = import ./3.10-html.nix {
        inherit stdenv fetchurl lib;
      };
    };
    pdf_a4 = {
      recurseForDerivations = true;
      python27 = import ./2.7-pdf-a4.nix {
        inherit stdenv fetchurl lib;
      };
      python310 = import ./3.10-pdf-a4.nix {
        inherit stdenv fetchurl lib;
      };
    };
    pdf_letter = {
      recurseForDerivations = true;
      python27 = import ./2.7-pdf-letter.nix {
        inherit stdenv fetchurl lib;
      };
      python310 = import ./3.10-pdf-letter.nix {
        inherit stdenv fetchurl lib;
      };
    };
    text = {
      recurseForDerivations = true;
      python27 = import ./2.7-text.nix {
        inherit stdenv fetchurl lib;
      };
      python310 = import ./3.10-text.nix {
        inherit stdenv fetchurl lib;
      };
    };
    texinfo = {
      recurseForDerivations = true;
      python310 = import ./3.10-texinfo.nix {
        inherit stdenv fetchurl lib;
      };
    };
  };
in
pythonDocs
