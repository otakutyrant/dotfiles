{ ... }:

{
  # Install personal executable scripts explicitly instead of discovering an
  # old Stow directory tree from the main Home Manager configuration.
  home.file.".local/bin" = {
    source = ../files/bin;
    recursive = true;
  };
}
