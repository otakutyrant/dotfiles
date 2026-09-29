{ lib, ... }:

let
  # Powerline glyphs require a Nerd Font or Powerline-compatible font. Kitty is
  # configured to use JetBrainsMono Nerd Font, so these separators render there.
  leftCap = "";
  rightCap = "";
in
{
  # Starship replaces Nushell's plain built-in prompt with a context-aware
  # prompt that shows Git, language runtimes, command status, and duration.
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$cmd_duration"
        "$status"
        "$line_break"
        "$character"
      ];
      right_format = "$time";

      directory = {
        format = "[${leftCap}](fg:blue)[ $path ]($style)[${rightCap} ](fg:blue)";
        style = "fg:white bg:blue bold";
        truncation_length = 3;
        truncation_symbol = ".../";
      };

      git_branch = {
        format = "[${leftCap}](fg:green)[ $symbol$branch ]($style)[${rightCap} ](fg:green)";
        style = "fg:black bg:green bold";
        symbol = " ";
      };

      git_status = {
        format = "[${leftCap}](fg:yellow)[ $all_status$ahead_behind ]($style)[${rightCap} ](fg:yellow)";
        style = "fg:black bg:yellow bold";
      };

      cmd_duration = {
        format = "[${leftCap}](fg:purple)[ $duration ]($style)[${rightCap} ](fg:purple)";
        min_time = 2000;
        style = "fg:white bg:purple bold";
      };

      status = {
        disabled = false;
        format = "[${leftCap}](fg:red)[ exit $status ]($style)[${rightCap} ](fg:red)";
        style = "fg:white bg:red bold";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "dimmed white";
        time_format = "%H:%M";
      };
    };
  };
}
