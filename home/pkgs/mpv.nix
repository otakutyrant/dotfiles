# mpv depends on libass which is not built with libunibreak. So overwrite
# them here.
{
  libass,
  libunibreak,
  mpv, # It is just a wrapper, not a real packages.
  mpv-unwrapped, # The real mpv binary package from nixpkgs.
}:

mpv.override {
  mpv-unwrapped = mpv-unwrapped.override {
    libass = libass.overrideAttrs (oldAttrs: {
      configureFlags = (oldAttrs.configureFlags or [ ]) ++ [ "--enable-libunibreak" ];
      # Add libunibreak, which lets libass wrap long Chinese subtitle lines.
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ libunibreak ];
    });
  };
}
