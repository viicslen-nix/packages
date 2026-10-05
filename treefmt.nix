{
  projectRootFile = "flake.nix";
  programs = {
    deadnix.enable = true;
    statix.enable = true;
    alejandra.enable = true;
    shfmt.enable = true;
  };
  settings.formatter = {
    # Lower runs first: the linters rewrite code, so alejandra must format after them.
    deadnix.priority = 1;
    statix.priority = 2;
    alejandra.priority = 3;
    # Indent case branches, as scripts/packages.sh is written.
    shfmt.options = ["-ci"];
  };
}
