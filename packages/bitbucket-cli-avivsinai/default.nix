{
  lib,
  buildGoModule,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  # Keep this distinct from nixpkgs' unrelated bkt and bitbucket-cli packages.
  pname = "bitbucket-cli-avivsinai";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "bitbucket-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AqSFyy6Y9ynZTx464WepzhlYdLrJlJEfa/T6tP2ygJo=";
  };

  vendorHash = "sha256-lZ1/EFTS9dVH844Z3q7qEdWFo673nTGmDA84WCT777M=";

  subPackages = [ "cmd/bkt" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/avivsinai/bitbucket-cli/internal/build.versionFromLdflags=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ gitMinimal ];

  # The command package has no tests; run the full upstream suite instead.
  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  postInstall = ''
    installShellCompletion --cmd bkt \
      --bash <("$out/bin/bkt" completion bash) \
      --zsh <("$out/bin/bkt" completion zsh) \
      --fish <("$out/bin/bkt" completion fish)
  '';

  meta = {
    description = "Bitbucket CLI for Bitbucket Cloud and Data Center";
    homepage = "https://github.com/avivsinai/bitbucket-cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "bkt";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
