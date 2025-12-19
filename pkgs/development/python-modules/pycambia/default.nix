{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  openssl,
  pkg-config,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pycambia";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KyokoMiki";
    repo = "pycambia";
    rev = version;
    hash = "sha256-ZflLy6Qa4tBlPZkTya3ELu463qcnRcMS57a6FfHpSNE=";
  };

  patches = [ ./add-Cargo.lock.patch ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-jD2qSHjqa/NHJniulVqVQ/vkszsiHidneubhK2kc/nM=";
    patches = [ ./add-Cargo.lock.patch ];
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "cambia" ];

  meta = {
    description = "Python wrapper for compact disc ripper log checking utility cambia";
    homepage = "https://github.com/KyokoMiki/pycambia";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ undefined-landmark ];
  };
}
