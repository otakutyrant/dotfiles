{ pkgs, ... }:

{
  # Stasis is a Rust idle manager with native support for niri.
  home.packages = [ pkgs.stasis ];

  # Generate the idle policy through Home Manager instead of linking a
  # separate dotfile directory. Stasis applies action timeouts sequentially.
  xdg.configFile."stasis/stasis.rune".text = ''
    @author "otakutyrant"
    @description "Niri idle policy"

    default:
      # Track suspend and resume through logind, and respect applications that ask
      # the desktop to remain active, such as browsers playing video.
      enable_loginctl true
      enable_dbus_inhibit true
      pre_suspend_command None
      monitor_media true
      ignore_remote_media true
      debounce_seconds 0
      notify_on_unpause false
      notify_before_action false
      inhibit_apps [ ]

      # Lock after ten idle minutes, then power off the monitors one second
      # later. Niri powers them back on when input resumes.
      lock_screen:
        timeout 600
        command "cthulock"
      end

      dpms:
        timeout 1
        command "niri msg action power-off-monitors"
      end
    end
  '';
}
