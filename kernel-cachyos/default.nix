{
  inputs,
  callPackage,
  lib,
  linux_latest,
  linux,
  ...
}:
let
  mkCachyKernel = callPackage ./mkCachyKernel.nix { inherit inputs; };

  batch =
    {
      pnameSuffix,
      version,
      src,
      configVariant,
      ...
    }:
    [
      (mkCachyKernel {
        pnameSuffix = "${pnameSuffix}";
        inherit version src configVariant;
        lto = false;
      })
      (mkCachyKernel {
        pnameSuffix = "${pnameSuffix}-lto";
        inherit version src configVariant;
        lto = true;
      })
    ];

  batches = [
    (batch {
      pnameSuffix = "latest";
      inherit (linux_latest) version src;
      configVariant = "linux-cachyos";
    })
    (batch {
      pnameSuffix = "lts";
      inherit (linux) version src;
      configVariant = "linux-cachyos-lts";
    })
  ];
in
builtins.listToAttrs (lib.flatten batches)
