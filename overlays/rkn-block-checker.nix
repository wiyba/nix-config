{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "rkn-block-checker";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MayersScott";
    repo = "rkn-block-checker";
    rev = "v${version}";
    hash = "sha256-9redAEo+XytK7k2w5VDX4c1lgMqxnwNzSaDVAr1Jzjw=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ requests ];

  pythonImportsCheck = [ "rkn_checker" ];

  meta = with lib; {
    description = "Internet block diagnosis tool";
    homepage = "https://github.com/MayersScott/rkn-block-checker";
    license = licenses.mit;
    mainProgram = "rkn-check";
    platforms = platforms.linux;
  };
}
