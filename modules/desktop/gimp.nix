{ lib, pkgs, ... }:
let
  gimpStartupScript = ''
    (begin
      (gimp-context-set-foreground "#ffffff")
      (gimp-context-set-background "#000000")
      (gimp-context-set-paint-method "gimp-paintbrush")
      (gimp-context-set-brush "2. Hardness 100")
      (let* (
              (image (car (gimp-image-new 1920 1080 RGB)))
              (layer (car (gimp-layer-new image 1920 1080 RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL)))
            )
        (gimp-drawable-fill layer BACKGROUND-FILL)
        (gimp-image-insert-layer image layer 0 0)
        (gimp-display-new image)
        (gimp-displays-flush)))
  '';

  gimpWrapper = pkgs.writeShellScriptBin "gimp" ''
    if [ "$#" -gt 0 ]; then
      exec ${pkgs.gimp}/bin/gimp "$@"
    fi

    exec ${pkgs.gimp}/bin/gimp \
      --new-instance \
      --batch-interpreter=plug-in-script-fu-eval \
      --batch ${lib.escapeShellArg gimpStartupScript}
  '';

  gimpDesktop = pkgs.makeDesktopItem {
    name = "gimp";
    desktopName = "GIMP";
    exec = "gimp %F";
    icon = "org.gimp.GIMP";
    terminal = false;
    categories = [
      "Graphics"
      "2DGraphics"
      "RasterGraphics"
    ];
    mimeTypes = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/tiff"
      "image/webp"
      "image/x-xcf"
    ];
  };

  gimpCustom = pkgs.symlinkJoin {
    name = "gimp-cyber";
    paths = [
      pkgs.gimp
      gimpWrapper
      gimpDesktop
    ];
    postBuild = ''
      rm -f $out/bin/gimp
      ln -s ${gimpWrapper}/bin/gimp $out/bin/gimp
    '';
  };
in
{
  environment.systemPackages = [
    gimpCustom
  ];
}
