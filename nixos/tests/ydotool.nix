{
  system ? builtins.currentSystem,
  config ? { },
  pkgs ? import ../.. { inherit system config; },
  lib ? pkgs.lib,
}:
let
  makeTest = import ./make-test-python.nix;
  textInput = "This works.";
  inputBoxText = "Enter input";
  inputBox = pkgs.writeShellScript "zenity-input" ''
    ${lib.getExe pkgs.gnome.zenity} --entry --text '${inputBoxText}:' > /tmp/output &
  '';
  asUser = ''
    def as_user(cmd: str) -> str:
      """Return a shell command for running a shell command as a specific user."""
      return f"sudo -u alice -i {cmd}"
  '';
in
{
  headless = makeTest {
    name = "ydotool-headless";

    enableOCR = true;

    nodes.machine = {
      imports = [ ./common/user-account.nix ];
      users.users.alice.extraGroups = [ "ydotool" ];
      programs.ydotool.enable = true;
      services.getty.autologinUser = "alice";
    };

    testScript = ''
      ${asUser}

      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_text("alice")
      machine.succeed(as_user("ydotool type 'echo ${textInput} > /tmp/output'")) # text input
      machine.succeed(as_user("ydotool key 28:1 28:0")) # text input
      machine.screenshot("headless_input")
      machine.wait_for_file("/tmp/output")
      machine.wait_until_succeeds("grep '${textInput}' /tmp/output") # check for success
    '';

    meta.maintainers = with lib.maintainers; [
      OPNA2608
      quantenzitrone
    ];
  };

  x11 = makeTest {
    name = "ydotool-x11";

    enableOCR = true;

    nodes.machine = {
      imports = [
        ./common/user-account.nix
        ./common/auto.nix
        ./common/x11.nix
      ];
      users.users.alice.extraGroups = [ "ydotool" ];
      programs.ydotool.enable = true;
      test-support.displayManager.auto = {
        enable = true;
        user = "alice";
      };
      services.xserver.windowManager.dwm.enable = true;
      services.displayManager.defaultSession = lib.mkForce "none+dwm";
    };

    testScript = ''
      ${asUser}

      start_all()
      machine.wait_for_x()
      machine.wait_for_unit("ydotoold.service")
      machine.execute(as_user("${inputBox}"))
      machine.wait_for_text("${inputBoxText}")
      machine.succeed(as_user("ydotool type '${textInput}'")) # text input
      machine.screenshot("x11_input")
      machine.succeed(as_user("ydotool mousemove -a 400 110")) # mouse input
      machine.succeed(as_user("ydotool click 0xC0")) # mouse input
      machine.wait_for_file("/tmp/output")
      machine.wait_until_succeeds("grep '${textInput}' /tmp/output") # check for success
    '';

    meta.maintainers = with lib.maintainers; [
      OPNA2608
      quantenzitrone
    ];
  };

  wayland = makeTest {
    name = "ydotool-wayland";

    enableOCR = true;

    nodes.machine = {
      imports = [ ./common/user-account.nix ];
      users.users.alice.extraGroups = [ "ydotool" ];
      services.cage = {
        enable = true;
        user = "alice";
      };
      programs.ydotool.enable = true;
      services.cage.program = inputBox;
    };

    testScript = ''
      ${asUser}

      start_all()
      machine.wait_for_unit("graphical.target")
      machine.wait_for_unit("ydotoold.service")
      machine.wait_for_text("${inputBoxText}")
      machine.succeed(as_user("ydotool type '${textInput}'")) # text input
      machine.screenshot("wayland_input")
      machine.succeed(as_user("ydotool mousemove -a 100 100")) # mouse input
      machine.succeed(as_user("ydotool click 0xC0")) # mouse input
      machine.wait_for_file("/tmp/output")
      machine.wait_until_succeeds("grep '${textInput}' /tmp/output") # check for success
    '';

    meta.maintainers = with lib.maintainers; [
      OPNA2608
      quantenzitrone
    ];
  };

  customGroup =
    let
      insideGroupUsername = "ydotool-user";
      outsideGroupUsername = "other-user";
      groupName = "custom-group";
    in
    makeTest {
      name = "ydotool-custom-group";

      nodes."machine" = {
        programs.ydotool = {
          enable = true;
          group = groupName;
        };

        users.users = {
          "${insideGroupUsername}" = {
            isNormalUser = true;
            extraGroups = [ groupName ];
          };
          "${outsideGroupUsername}".isNormalUser = true;
        };
      };

      testScript = ''
        start_all()

        # Wait for service to start
        machine.wait_for_unit("multi-user.target")
        machine.wait_for_unit("ydotoold.service")

        # Verify that user with the configured group can use the service
        machine.succeed("sudo --login --user=${insideGroupUsername} ydotool type 'Hello, World!'")

        # Verify that user without the configured group can't use the service
        machine.fail("sudo --login --user=${outsideGroupUsername} ydotool type 'Hello, World!'")
      '';

      meta.maintainers = with lib.maintainers; [ l0b0 ];
    };
}
