{pkgs}:
with pkgs; let
  version = "4.0.0";
in
  vimUtils.buildVimPlugin {
    pname = "laravel.nvim";
    inherit version;

    src = fetchFromGitHub {
      owner = "adalessa";
      repo = "laravel.nvim";
      tag = "v${version}";
      sha256 = "sha256-v15qvgezkrosEZUVJlwXhir3p0fnLNWTo2XZOwk+SIE=";
    };

    buildInputs = with vimPlugins; [
      nvim-treesitter-parsers.php
      nvim-treesitter-parsers.json
      # v4 moved from promise-async to nvim-nio
      nvim-nio
      nui-nvim
      vim-dotenv
      plenary-nvim
      telescope-nvim
      fzf-lua
      snacks-nvim
    ];

    nvimSkipModule = [
      # optional mcphub.nvim integration; that plugin fails its own require check in nixpkgs
      "laravel.extensions.mcp.artisan_tool"
      "laravel.extensions.mcp.composer_tool"
      # upstream bug: requires laravel.pickers.ui_select.actions, which does not exist in v4
      "laravel.pickers.providers.ui_select.routes"
    ];
  }
