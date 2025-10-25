## Usage

1. Ensure you have installed the [dependencies](#dependencies) for your operating system.
2. Download your chosen flavour + accent zip file from the [latest GitHub release](https://github.com/catppuccin/sddm/releases/latest).
3. Unzip the file and move the resulting directory to `/usr/share/sddm/themes/`. E.g. to copy `catppuccin-mocha-mauve`:

    ```bash
    sudo mv -v catppuccin-mocha-mauve /usr/share/sddm/themes
    ```

4. Edit the `/etc/sddm.conf` file and change the theme to `catppuccin-<flavour>-<accent>`. For example, `catppuccin-mocha-mauve`.

   If you don't have this file, create the `/etc/sddm.conf` file and add the following lines:

   ```conf
   [Theme]
   Current=catppuccin-mocha-blue
   ```

5. Unfortunately, the theme does not work properly if SDDM is run on X11 and not Wayland - follow the instructions [here](https://wiki.archlinux.org/title/SDDM#Wayland) here if there are issues. 

## Dependencies

### Arch Based OS

```bash
pacman -Syu qt6-svg qt6-declarative qt5-quickcontrols2
```

