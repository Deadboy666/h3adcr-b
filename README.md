# <img src="https://github.com/Deadboy666/h3adcr-b-modul3s/blob/main/headcrab.png?raw=true" alt="Project Logo" width="175" height="175">h3adcr-b
Headcrab is a rootless Steam client compatibility helper
- **Requirements**: `wget`, `curl`, `grep`, `awk`, `sed`, `7zip`
## Features
- Installs the latest SLSsteam release.
- Overides Steam client updates to maintain compatibility with SLSsteam updates.
- Rootless operation* *As Long as The Dependacies Are Met.*
- Updates Users SLSsteam config.
## How it works
1. Detects Steam install type: Native, Flatpak, or SteamOS.
2. Reads the installed Steam client manifest and compares it against the compatible version.
3. If compatible, it installs and setup SLSsteam injection.
4. If incompatible, it fetches the required client files and forces a client update using a local override URL.
5. Patches Steam launch scripts to enable LD_AUDIT injection and updates SLSsteam config.
   
## Disclaimer For Steamos Users
- Since how steamos is done forcing bash to be in exit one theres one extra step you have to do.
- You only have to do it once before running headcrab if its your first time using it.
- follow the steps linked here then run headcrab :)
- https://github.com/Deadboy666/h3adcr-b/wiki/Headcrab-Troubleshooting-For-Steamos

## Supported Client Installs:
  - Native Installs (The Native Package That You Install On Your Distro)
  - Flatpak Installs (Its Native In A Limited Container)
  - Handheld/HTPC Installs (ex. `SteamOS`, `CachyOS`, `Chimera`, `Bazzite`,`Nobara`)

 ## Distro's Supported By h3adcr-b.
   * Fedora Based Distros
      - Mutable (Normally Fedora Spins.)
      - Atomic (Ublue Based Distros)
        
   * Arch Based Distros
     - Arch Based Distros (ex. `Manjaro`, `CachyOS`, `Endevour`, `ArchBTW`)
       
   * Ubuntu/Debian Based Distros.
   * Void Linux Based Distros.
 ## Getting Started
 * Installing Headcrab
 * Cloudflare Redirect.
```bash
curl -fsSL headcrab.pages.dev | bash
```
* Incase the Redirect Doesnt work.
```bash
curl -fsSL "https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/main/headcrab.sh" | bash
```

- For Troubleshooting h3adcr-b* [View the Wiki](https://github.com/Deadboy666/h3adcr-b/wiki/Headcrab-Wiki)





