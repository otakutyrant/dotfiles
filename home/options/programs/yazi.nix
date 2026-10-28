{ pkgs, ... }:

{
  # Yazi replaces Joshuto with native previews, a Git status header, archive
  # previews, and an explicit Vim-like navigation layer for this workstation.
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";

    # Keep archive previews available through the packaged Yazi plugin and its
    # existing ouch package instead of maintaining a separate preview script.
    extraPackages = [ pkgs.ouch ];
    plugins = {
      git = pkgs.yaziPlugins.git;
      githead = pkgs.yaziPlugins.githead;
      git-repo = ../../files/config/yazi/plugins/git-repo.yazi;
      ouch = pkgs.yaziPlugins.ouch;
    };
    initLua = ../../files/config/yazi/init.lua;

    settings = {
      mgr = {
        ratio = [
          1
          3
          4
        ];
        linemode = "size";
        sort_by = "natural";
        sort_dir_first = true;
        show_hidden = false;
      };
      opener = {
        edit = [
          {
            run = "nvim %s";
            block = true;
            desc = "Edit";
            "for" = "unix";
          }
        ];
        open = [
          {
            run = "xdg-open %s1";
            orphan = true;
            desc = "Open";
            "for" = "unix";
          }
        ];
      };
      open.prepend_rules = [
        {
          mime = "text/*";
          use = "edit";
        }
        {
          mime = "application/json";
          use = "edit";
        }
        {
          mime = "application/xml";
          use = "edit";
        }
      ];
      plugin.prepend_previewers = [
        {
          mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
          run = "ouch";
        }
      ];
      plugin.prepend_fetchers = [
        {
          url = "*";
          run = "git";
          group = "git";
        }
        {
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "q";
          run = "quit";
          desc = "Quit";
        }
        {
          on = "<C-q>";
          run = "close";
          desc = "Close tab";
        }
        {
          on = "h";
          run = "leave";
          desc = "Leave directory";
        }
        {
          on = "l";
          run = "enter";
          desc = "Enter directory";
        }
        {
          on = "j";
          run = "arrow 1";
          desc = "Move down";
        }
        {
          on = "k";
          run = "arrow -1";
          desc = "Move up";
        }
        {
          on = [
            "g"
            "g"
          ];
          run = "arrow top";
          desc = "Go to first entry";
        }
        {
          on = "G";
          run = "arrow bot";
          desc = "Go to last entry";
        }
        {
          on = "<C-u>";
          run = "arrow -50%";
          desc = "Move half page up";
        }
        {
          on = "<C-d>";
          run = "arrow 50%";
          desc = "Move half page down";
        }
        {
          on = "<Space>";
          run = "toggle";
          desc = "Toggle selection";
        }
        {
          on = [
            "d"
            "d"
          ];
          run = "yank --cut";
          desc = "Cut selected files";
        }
        {
          on = "y";
          run = "yank";
          desc = "Copy selected files";
        }
        {
          on = "p";
          run = "paste";
          desc = "Paste files";
        }
        {
          on = "P";
          run = "paste --force";
          desc = "Paste and overwrite";
        }
        {
          on = "d";
          run = "remove";
          desc = "Move to trash";
        }
        {
          on = "r";
          run = "rename";
          desc = "Rename";
        }
        {
          on = [
            "z"
            "h"
          ];
          run = "hidden toggle";
          desc = "Toggle hidden files";
        }
        {
          on = "<Esc>";
          run = "escape";
          desc = "Cancel";
        }
      ];
    };
  };
}
