## Usage

### Color Palette

Replace the variables `<flavor>` and `<accent>` with the values that you want to use from the [themes](./themes) folder. E.g. (flavor as `mocha` and accent as `mauve`)

Copy the `.soc` file (`themes/<flavor>/<accent>/catppuccin-<flavor>-<accent>.soc`) to the correct path for your operating system:

- **Linux**: `${XDG_CONFIG_HOME:-$HOME/.config}"/libreoffice/*/user/config/`
- **macOS**: `$HOME/Library/Application Support/LibreOffice"/*/user/config/`
- **Windows**: `$HOME/AppData/Roaming/LibreOffice"/*/user/config/`

### Application Colors

> [!WARNING]  
> This will backup and overwrite the `registrymodifications.xcu` configuration file.

Run the [scripts/install_theme.sh](./scripts/install_theme.sh) script.

E.g. `./scripts/install_theme.sh mocha mauve`
