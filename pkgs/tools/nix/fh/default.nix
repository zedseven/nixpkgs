{ lib
, rustPlatform
, fetchFromGitHub
, installShellFiles
, stdenv
, darwin
, gcc
, libcxx
}:

rustPlatform.buildRustPackage rec {
  pname = "fh";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "fh";
    rev = "v${version}";
    hash = "sha256-O0WcLEtbb5m3RA3LyWbD++fFt0Bk/pP16yhxRb+cGkM=";
  };

  cargoHash = "sha256-cGBYDwrw4NsbtE5bhETQ+YuBXMy1i7vNQaoTiuHYBXQ=";

  nativeBuildInputs = [
    installShellFiles
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    gcc.cc.lib
  ];

  env = lib.optionalAttrs stdenv.isDarwin {
    NIX_CFLAGS_COMPILE = "-I${lib.getDev libcxx}/include/c++/v1";
  };

  postInstall = ''
    installShellCompletion --cmd fh \
      --bash <($out/bin/fh completion bash) \
      --fish <($out/bin/fh completion fish) \
      --zsh <($out/bin/fh completion zsh)
  '';

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "The official FlakeHub CLI";
    homepage = "https://github.com/DeterminateSystems/fh";
    changelog = "https://github.com/DeterminateSystems/fh/releases/tag/${src.rev}";
    license = licenses.asl20;
    maintainers = with maintainers; [ figsoda ];
    mainProgram = "fh";
  };
}
