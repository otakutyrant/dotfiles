{ pkgs, ... }:

{
  # User-wide Git settings. Home Manager renders this to ~/.config/git/config.
  programs.git = {
    enable = true;
    package = pkgs.git;
    settings = {
      alias = {
        c = "commit";
        d = "diff";
        # Keep Difftastic opt-in: ordinary `git diff` remains available when a
        # conventional patch is more useful than a syntax-aware review.
        dft = "-c diff.external=difft diff";
        ds = "-c diff.external=difft show --ext-diff";
        dl = "-c diff.external=difft log -p --ext-diff";
        s = "status";
        g = "log --name-only --graph --all --date=format-local:'%Y-%m-%d %H:%M:%S' --format='%C(auto)%h%d %cd %s'";
        l = "log --name-only";
      };
      # GitHub CLI owns mutable authentication state, while Git delegates only
      # GitHub HTTPS credential requests to its authenticated account.
      credential = {
        "https://github.com".helper = [
          ""
          "${pkgs.gh}/bin/gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      status.showStash = true;
      user = {
        name = "otakutyrant";
        email = "otakutyrant@gmail.com";
      };
    };
  };
}
