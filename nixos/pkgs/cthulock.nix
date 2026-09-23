{
  inputs,
  pkgs,
  ...
}:

{
  # Cthulock is not in the pinned nixpkgs release, so install it from the
  # upstream flake input. NixOS declares its PAM service in configuration.nix.
  home.packages = [
    inputs.cthulock.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Generate the Slint interface through Home Manager instead of linking a
  # separate dotfile directory. Cthulock checks these properties and callbacks
  # before it acquires the secure Wayland session lock.
  xdg.configFile."cthulock/style.slint".text = ''
    import { LineEdit } from "std-widgets.slint";

    export component LockScreen inherits Window {
        in property<string> clock_text;
        in property<bool> checking_password;
        in-out property<string> password <=> password.text;
        callback submit <=> password.accepted;
        forward-focus: password;

        states [
            checking when checking-password : {
                password.enabled: false;
            }
        ]

        Rectangle {
            background: #1e1e2e;

            VerticalLayout {
                alignment: center;
                spacing: 16px;
                padding: 40px;
                width: 420px;

                Text {
                    text: clock_text;
                    horizontal-alignment: center;
                    font-size: 60pt;
                    color: #cdd6f4;
                }

                Text {
                    text: "Locked";
                    horizontal-alignment: center;
                    font-size: 20pt;
                    color: #bac2de;
                }

                password := LineEdit {
                    enabled: true;
                    horizontal-alignment: left;
                    input-type: InputType.password;
                    placeholder-text: "Password";
                }
            }
        }
    }
  '';
}
