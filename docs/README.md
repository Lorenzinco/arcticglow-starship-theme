# Arctic Glow

Arctic Glow is a refined prompt theme for [Starship](https://starship.rs), inspired by the original Oh My Zsh/Agnoster-style Arctic Glow look.

![Example](example.png)

## Installation

- You need to have [Starship](https://starship.rs) and a [Nerd Font](https://www.nerdfonts.com) installed.
- Clone the repository:

  ```sh
  git clone https://github.com/Lorenzinco/arcticglow-starship-theme.git
  ```

- Run the installation script:

  ```sh
  cd arcticglow-starship-theme
  ./install.sh
  ```

The installer will:

- verify that `starship` is available in your `PATH`
- copy `arcticglow.toml` to `~/.config/starship_themes/arcticglow.toml`
- set `STARSHIP_CONFIG` in your shell rc file so Starship loads Arctic Glow
- make sure your shell rc file contains the correct Starship initialization

The installer supports `bash`, `zsh`, `fish`, `tcsh`, `xonsh`, `elvish`, `nushell`, `powershell`, and `ion`. Starship's Windows `cmd` support depends on Clink and must be configured manually in the Clink scripts directory.

Reload your terminal after installation.

## Configuration

The theme lives at:

```sh
~/.config/starship_themes/arcticglow.toml
```

To customize Arctic Glow, edit that file directly. For example, you can adjust the palette, symbols, prompt modules, or segment formatting in the Starship TOML configuration.

If you already manage your Starship configuration manually, make sure your shell rc file points Starship at the theme before Starship is initialized:

```sh
export STARSHIP_CONFIG="$HOME/.config/starship_themes/arcticglow.toml"
eval "$(starship init zsh)"
```

For Fish, use:

```fish
set -gx STARSHIP_CONFIG ~/.config/starship_themes/arcticglow.toml
starship init fish | source
```

For other supported shells, `install.sh` writes the matching Starship initialization snippet to that shell's rc/profile file.
