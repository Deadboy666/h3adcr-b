#!/usr/bin/env bash


    #Headcrab Compatibile Client Version
    HeadcrabCompatibleClientVer=1782257239
    
    #Paths
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
	ApplicationDirectory=$HOME/.local/share/applications
	IconDirectory=$HOME/.local/share/icons/hicolor/48x48/apps
    SteamInstallDir=$HOME/.steam/steam
    FlatpakCloudRedirectDir=$HOME/.var/app/com.valvesoftware.Steam/.local/share/CloudRedirect
	FlatpakSteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.steam/steam
    FlatpakSLSsteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam
    FlatpakSLSsteamConfigDir=$HOME/.var/app/com.valvesoftware.Steam/.config/SLSsteam
    CloudRedirectDir=$HOME/.local/share/CloudRedirect
	SLSsteamInstallDir=$HOME/.local/share/SLSsteam
    SLSsteamConfigDir=$HOME/.config/SLSsteam
    InstallDir=$SCRIPT_DIR/SLSsteam_Download/bin
    Headcrab_Downgrader_Path=$HOME/.headcrab
	
	#URL'S
    Headcrab_Downgrade_URL="http://localhost:1666/"
	LinuxClientManifest="https://raw.githubusercontent.com/Deadboy666/SteamTracking/refs/heads/headcrab/ClientManifest/steam_client_ubuntu12"
    DeckClientManifest="https://raw.githubusercontent.com/Deadboy666/SteamTracking/refs/heads/headcrab/ClientManifest/steam_client_steamdeck_stable_ubuntu12"
	Headcrab_Native="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/main/headcrab_native.sh"
    Headcrab_Native_CR="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/cr-test/headcrab_native.sh"
	Headcrab_Flatpak="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/main/headcrab_flatpak.sh"
    Headcrab_Flatpak_CR="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/cr-test/headcrab_flatpak.sh"
	Headcrab_Client="https://raw.githubusercontent.com/Deadboy666/SteamTracking/refs/heads/master/ClientExtracted/steam.sh"
	CloudRedirectLib="https://github.com/Selectively11/h3adcr-b/releases/download/linux-test/cloud_redirect.so"
    dgsc="https://github.com/Deadboy666/h3adcr-b-modul3s/raw/refs/heads/main/dgsc"
    dlm="https://github.com/Deadboy666/h3adcr-b-modul3s/raw/refs/heads/main/dlm"
	cloudredirect="https://raw.githubusercontent.com/Selectively11/CloudRedirect/refs/heads/gh-pages/cloudredirect.flatpakrepo"
    flathub="https://dl.flathub.org/repo/flathub.flatpakrepo"
    Sources="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/main/sources.txt"
	Headcrab_Updater="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/main/headcrab.desktop"
	Headcrab_Icon="https://raw.githubusercontent.com/Deadboy666/h3adcr-b-modul3s/refs/heads/main/headcrab.png"
	
    read_os_release(){
        local f
        OS_ID=""
        OS_ID_LIKE=""
        for f in /etc/os-release /usr/lib/os-release; do
            [ -r "$f" ] || continue
            . "$f"
            break
        done
        OS_ID=${ID:-}
        OS_ID_LIKE=${ID_LIKE:-}
    }

    archcheck(){
        read_os_release
        case " $OS_ID $OS_ID_LIKE " in
            *" arch "*|*" cachyos "*) return 0 ;;
        esac
        return 1
        }

    debiancheck(){
        read_os_release
        case " $OS_ID $OS_ID_LIKE " in
            *" debian "*|*" ubuntu "*) return 0 ;;
        esac
        return 1
        }   

    steamoscheck(){
        read_os_release
        [ "$OS_ID" = "steamos" ]
        }
		
	voidcheck(){
        read_os_release
        [ "$OS_ID" = "void" ]
        }
	
	cachyoscheck(){
        read_os_release
        [ "$OS_ID" = "cachyos" ]
        }
		
	bazzitecheck(){
        read_os_release
        [ "$OS_ID" = "bazzite" ]
        }
    
    flatpakcheck(){
        [ -d "$FlatpakSteamInstallDir" ]
        }
    
    crconfigcheck(){
      whereSLSsteamconfig
        grep -F "DisableCloud: no" config.yaml &> /dev/null
        }
		
		SetupHeadcrab_Updater(){
		mkdir -p $ApplicationDirectory
		mkdir -p $IconDirectory
		cd $IconDirectory/
		wget -O headcrab.png "$Headcrab_Icon" &> /dev/null
		cd $ApplicationDirectory/
			wget -O headcrab.desktop "$Headcrab_Updater" &> /dev/null
		    chmod +x headcrab.desktop
			update-desktop-database $ApplicationDirectory
			echo "Headcrab Updater Now In Your Applications Menu"
			echo "Can Open Up Headcrab Updater To Update To Latest Version."
	}
        
    SteamOSClientCheck(){
        if [ -f "steam_client_steamdeck_stable_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_stable_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable"
        elif [ -f steam_client_steamdeck_publicbeta_ubuntu12.manifest ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
			echo "SteamClientChannel: Beta"
			echo "Reverting To Stable Client With DGSC"
		else
			echo "Unknown Version Number"
        fi
            echo "SteamClientType: SteamOS"
        }
		
	BazziteClientCheck(){
        if [ -f "steam_client_steamdeck_stable_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_stable_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable (Bazzite-Deck)"
        elif [ -f steam_client_steamdeck_publicbeta_ubuntu12.manifest ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta (Bazzite-Deck)"
		elif [ -f "steam_client_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable (Bazzite-Desktop)"
		else
            versionnumber=$(grep '"version"' steam_client_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta (Bazzite-Desktop)"
        fi
            echo "SteamClientType: Bazzite"
        }

	CachyClientCheck(){
        if [ -f "steam_client_steamdeck_stable_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_stable_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable (CachyOS-Handheld)"
        elif [ -f steam_client_steamdeck_publicbeta_ubuntu12.manifest ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta (CachyOS-Handheld)"
		elif [ -f "steam_client_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable (CachyOS-Desktop)"
		else
            versionnumber=$(grep '"version"' steam_client_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta (CachyOS-Desktop)"
        fi
            echo "SteamClientType: CachyOS"
        }

    FlatpakClientCheck(){
        if [ -f "steam_client_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable"
        else
            versionnumber=$(grep '"version"' steam_client_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta"
        fi
            echo "SteamClientType: Flatpak"
        }

    NativeClientCheck(){
        if [ -f "steam_client_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable"
        else
            versionnumber=$(grep '"version"' steam_client_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta"
        fi
            echo "SteamClientType: Native"
        }
		
	VoidClientCheck(){
        if [ -f "steam_client_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable"
        else
            versionnumber=$(grep '"version"' steam_client_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta"
        fi
            echo "SteamClientType: Void"
        }
		
    CheckClientInfo(){
        echo "SteamClientInfo:"
        wheresteampackage
        if steamoscheck; then
            SteamOSClientCheck
		elif bazzitecheck; then
            BazziteClientCheck
		elif cachyoscheck; then
			CachyClientCheck
		elif voidcheck; then
			VoidClientCheck
        elif flatpakcheck; then
            FlatpakClientCheck
        else
            NativeClientCheck
        fi
            echo "SteamClientVersion: $versionnumber"
            }
    
    CheckHeadcrabCompatibility(){
            echo "=================================================="
        CheckClientInfo
        if [[ "$versionnumber" == "$HeadcrabCompatibleClientVer" ]]; then
            echo "ClientCompatCheck: SteamClientVersion Compatible"
            echo "================================================="
            clientinstall
        else
            echo "ClientCompatCheck: SteamClientVersion Incompatible"
            echo "=================================================="
            echo "Bootstrapping Injector"
            clientdowngrade
        fi
        }

    preinstallchecks(){
        InstallVoidDeps
		InstallDebianDeps
		InstallArchDeps
        RemoveArchPkg
        DisableSLSsteamPath
        }

    InstallDebianDeps() {	    
	    if debiancheck; then

		if apt-cache search --names-only '^libcurl4t64$' | grep -q "libcurl4t64"; then
		    pkg_name="libcurl4t64"
		else
		    pkg_name="libcurl4"
		fi
		target_pkg="${pkg_name}:i386"

		if dpkg -s "$target_pkg" >/dev/null 2>&1; then
		    echo -e "$target_pkg already installed"
		    return 0
		fi

		if ! dpkg --print-foreign-architectures | grep -q "i386"; then
		    echo "Adding i386 architecture..."
		    sudo dpkg --add-architecture i386
		    sudo apt-get update >/dev/null 2>&1
		fi

		if sudo apt-get install -y "$target_pkg" >/dev/null 2>&1; then
		    echo -e "$target_pkg installed successfully"
		else
		    echo -e "$target_pkg failed to install"
		fi

        fi
	    }
		
		InstallVoidDeps(){
        if voidcheck; then
            if ! command -v xbps-install >/dev/null 2>&1; then
                echo "Void Linux detected but xbps-install was not found in PATH"
                return 1
            fi

            local pkg cmd install_cmd
            local missing_pkgs=()
            local missing_cmds=()

            for pkg in wget curl grep gawk sed 7zip flatpak; do
                case "$pkg" in
                    gawk) cmd="awk" ;;
                    7zip) cmd="7z" ;;
                    *) cmd="$pkg" ;;
                esac

                if ! command -v "$cmd" >/dev/null 2>&1; then
                    missing_pkgs+=("$pkg")
                fi
            done

            if [ "${#missing_pkgs[@]}" -eq 0 ]; then
                echo "Void dependencies already installed"
                return 0
            fi

            if [ "$(id -u)" -eq 0 ]; then
                install_cmd="xbps-install"
            elif command -v sudo >/dev/null 2>&1; then
                install_cmd="sudo xbps-install"
            else
                echo "Void dependencies missing: ${missing_pkgs[*]}"
                echo "Install them with: xbps-install ${missing_pkgs[*]}"
                echo "Re-run as root or install sudo for automatic dependency installation"
                return 1
            fi

            echo "Installing missing Void dependencies: ${missing_pkgs[*]}"
            if ! $install_cmd -y "${missing_pkgs[@]}"; then
                echo "Failed to install Void dependencies: ${missing_pkgs[*]}"
                return 1
            fi

            for pkg in wget curl grep gawk sed 7zip flatpak; do
                case "$pkg" in
                    gawk) cmd="awk" ;;
                    7zip) cmd="7z" ;;
                    *) cmd="$pkg" ;;
                esac

                if ! command -v "$cmd" >/dev/null 2>&1; then
                    missing_cmds+=("$cmd")
                fi
            done

            if [ "${#missing_cmds[@]}" -ne 0 ]; then
                echo "Void dependencies still missing after install: ${missing_cmds[*]}"
                return 1
            fi

            echo "Void dependencies installed successfully"
        fi
    }
	
	InstallArchDeps(){
		if archcheck; then
		 local packages=("wget" "curl" "grep" "awk" "sed" "7zip" "flatpak")
	    local to_install=()
	
	    for pkg in "${packages[@]}"; do
	        if ! pacman -Qs "$pkg" &>/dev/null; then
	            to_install+=("$pkg")
	        fi
	    done
	
	    if [ ${#to_install[@]} -eq 0 ]; then
	        echo "All required packages are already installed."
	    else
	        echo "Installing missing packages: ${to_install[*]}"
	        sudo pacman -S "${to_install[@]}" --noconfirm
	    fi
		fi
	}

    RemoveArchPkg(){
        if archcheck; then
        installed_pkgs=$(pacman -Qq | grep -E '^slssteam(-git)?$' || true)
        if [ -n "$installed_pkgs" ]; then
            echo "Headcrab Will Transition To The Install To One That Can Seemlessly Update."
			echo "This Will Replace The System Package Of SLSsteam With One That Is Local."
            echo "Uninstalling Arch packages: $installed_pkgs"
            sudo pacman -Rns --noconfirm $installed_pkgs
        fi
        fi
    }

    DisableSLSsteamPath(){
        local local_target="$SLSsteamInstallDir/path/steam"
        local flatpak_target="$FlatpakSLSsteamInstallDir/path/steam"
        local acted=0

        if [ -e "$flatpak_target" ]; then
            echo "Found: $flatpak_target"
            echo "Renaming $flatpak_target -> ${flatpak_target}.bak"
            mv -- "$flatpak_target" "${flatpak_target}.bak"
            acted=1
        fi

        if [ -e "$local_target" ]; then
            echo "Found: $local_target"
            echo "Renaming $local_target -> ${local_target}.bak"
            mv -- "$local_target" "${local_target}.bak"
            acted=1
        fi

        if [ "$acted" -eq 0 ]; then
            echo "Not present: $flatpak_target"
            echo "Not present: $local_target"
        fi
    }
	
    TrashiteWatMani(){
		wheresteampackage
		if [ -f "steam_client_steamdeck_stable_ubuntu12.installed"]; then
			echo "Headcrab Downloading Bazzite-Deck Client Manifest"
			wget "$DeckClientManifest" &> /dev/null
		else
			echo "Headcrab Downloading Bazzite-Desktop Client Manifest"
			wget "$LinuxClientManifest" &> /dev/null
		fi
			echo "" &> /dev/null
		}

	CachyWatMani(){
		wheresteampackage
		if [ -f "steam_client_steamdeck_stable_ubuntu12.installed" ]; then
			echo "Headcrab Downloading CachyOS-Handheld Client Manifest"
			wget "$DeckClientManifest" &> /dev/null
		else
			echo "Headcrab Downloading CachyOS-Desktop Client Manifest"
			wget "$LinuxClientManifest" &> /dev/null
		fi
			echo "" &> /dev/null
		}
		
    DownloadClientManifest(){
	    if steamoscheck; then
	        echo "Headcrab Downloading Steamos Client Manifest.."
	        wget "$DeckClientManifest" &> /dev/null
		elif bazzitecheck; then
			TrashiteWatMani
		elif cachyoscheck; then
			CachyWatMani
	    else
	        echo "Headcrab Downloading Linux Client Manifest.."
	        wget "$LinuxClientManifest" &> /dev/null
	    fi
	        echo "Client Manifest Downloaded"
    }
    
    download_dgsc(){
        mkdir -p $Headcrab_Downgrader_Path
        cd $Headcrab_Downgrader_Path/
        if [ -f "$Headcrab_Downgrader_Path/dgsc" ]; then
            echo "Headcrab_dgsc Downloaded Already."
        else
            echo "Downloading Headcrab_dgsc.."
            wget "$dgsc" &> /dev/null
            chmod +x dgsc
        fi
          echo "" &> /dev/null
        }
        
        download_dlm(){
        mkdir -p $Headcrab_Downgrader_Path
        cd $Headcrab_Downgrader_Path/
        if [ -f "$Headcrab_Downgrader_Path/dlm" ]; then
            echo "Headcrab_dlm Downloaded Already."
        else
            echo "Downloading Headcrab_dlm.."
            wget "$dlm" &> /dev/null
            chmod +x dlm
        fi
          echo "" &> /dev/null
        }
        
        dlm(){
        download_dlm
        echo "Running Fetching Client Update Headcrab_dlm.."
        wheresteampackage
        $Headcrab_Downgrader_Path/dlm --input-file sources.txt --max-concurrent 16
        echo "Headcrab_dlm Fetched Client Update"
        }
        
    dgsc(){
        download_dgsc
        echo "Running Headcrab_dgsc.."
        wheresteampackage
        $Headcrab_Downgrader_Path/dgsc --port 1666 --silent & sleep 1s "$@"
        }
        
    prepdowngrade(){
        wheresteamcfg
        rm package/*
        wheresteampackage
        wget "$Sources" &> /dev/null
        DownloadClientManifest
        dlm
        }
        
    clientinstall(){
        echo "the headcrab latches on the steam process.."
		createsteamcfg
        if steamoscheck; then
            echo "Steamos Detected"
            echo "Headcrab Bootstrapping SLSsteam.."
           export_sls wheresteam -exitsteam
		elif bazzitecheck; then
			echo "Bazzite Detected"
            echo "Headcrab Bootstrapping SLSsteam.."
           export_sls wheresteam -exitsteam
		elif cachyoscheck; then
			echo "CachyOS Detected"
            echo "Headcrab Bootstrapping SLSsteam.."
           export_sls wheresteam -exitsteam
        elif flatpakcheck; then
            echo "Headcrab Bootstrapping SLSsteam.."  
			export_sls wheresteam -clearbeta steam://exit
		elif voidcheck; then
			echo "Void Linux"
			echo "Headcrab Bootstrapping SLSsteam.."  
			export_sls wheresteam -clearbeta steam://exit
		else
			export_sls wheresteam -clearbeta -exitsteam &> /dev/null
        fi
            echo "" &> /dev/null
            }
        
    clientdowngrade(){
        prepdowngrade
        overideupdate
        }
        
    nuketheclient(){
                killall steam | true
            }
        
    wheresteam(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                flatpak run com.valvesoftware.Steam "$@" &> /dev/null
        else
                steam "$@" &> /dev/null
            fi
                echo "" &> /dev/null
            }
            
    wheresteamdir(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                mkdir -p $FlatpakSLSsteamInstallDir
				mkdir -p $FlatpakCloudRedirectDir
                cp -f $InstallDir/library-inject.so $FlatpakSLSsteamInstallDir/
                cp -f $InstallDir/SLSsteam.so $FlatpakSLSsteamInstallDir/
        else
                 mkdir -p $CloudRedirectDir
				 mkdir -p $SLSsteamInstallDir
                 mkdir -p $SLSsteamConfigDir
                 cp -f $InstallDir/library-inject.so $SLSsteamInstallDir/
                 cp -f $InstallDir/SLSsteam.so $SLSsteamInstallDir/
            fi
				echo "" &> /dev/null
            }
            
    wheresteamcfg(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
               cd $FlatpakSteamInstallDir/
        else
                cd $SteamInstallDir/
            fi
                echo "" &> /dev/null
            }
			
	wheresteampackage(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
               cd $FlatpakSteamInstallDir/package
        else
                cd $SteamInstallDir/package
            fi
                echo "" &> /dev/null
            }

    whereSLSsteamconfig(){
        if [ -d "$FlatpakSLSsteamConfigDir" ]; then
               mkdir -p $FlatpakSLSsteamConfigDir
               cd $FlatpakSLSsteamConfigDir/
        else
                mkdir -p $SLSsteamConfigDir
                cd $SLSsteamConfigDir/
            fi
                echo "" &> /dev/null
            }
            
    overideupdate(){
        echo "the headcrab latches on the steam process.."
		killall dgsc | true
        if steamoscheck; then
            echo "Steamos Detected"
            createsteamcfg
            dgsc
            echo "Headcrab Connecting to The Updater.."
           export_sls wheresteam -textmode -forcesteamupdate -forcepackagedownload -overridepackageurl "$Headcrab_Downgrade_URL" -exitsteam &> /dev/null
		elif bazzitecheck; then
			echo "Bazzite Detected"
            createsteamcfg
            dgsc
            echo "Headcrab Connecting to The Updater.."
           export_sls wheresteam -textmode -forcesteamupdate -forcepackagedownload -overridepackageurl "$Headcrab_Downgrade_URL" -exitsteam &> /dev/null
        else
            createsteamcfg
            dgsc
            echo "Headcrab Connecting to The Updater.."
            export_sls wheresteam -clearbeta -textmode -forcesteamupdate -forcepackagedownload -overridepackageurl "$Headcrab_Downgrade_URL" -exitsteam &> /dev/null
        fi
            killall dgsc
            echo "Compatible Update Applied Via Headcrab_dgsc"
            }
            
    checkforsteamcfg(){
    echo "the headcrab approaches.."
    wheresteamcfg
        nuketheclient
        CheckHeadcrabCompatibility
        conditioncheck
        }

    downloadSLSsteam(){
            echo "Downloading Latest SLSsteam.."
            cd $SCRIPT_DIR/
            mkdir -p $SCRIPT_DIR/SLSsteam_Download
            cd SLSsteam_Download
            local TAG
            TAG=$(curl -sSL --connect-timeout 15 --max-time 30 \
                -o /dev/null -w "%{url_effective}" \
                "https://github.com/AceSLS/SLSsteam/releases/latest" 2>/dev/null)
            TAG="${TAG##*/}"
            wget -O SLSsteam-Any.7z \
                "https://github.com/AceSLS/SLSsteam/releases/download/$TAG/SLSsteam-Any.7z" &> /dev/null
        }
    
    export_sls(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                copySLSsteam
                LD_AUDIT=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/library-inject.so:$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/SLSsteam.so "$@"
        else
                copySLSsteam
                LD_AUDIT=$HOME/.local/share/SLSsteam/library-inject.so:$HOME/.local/share/SLSsteam/SLSsteam.so "$@"
        fi
                echo &> /dev/null
                }

    extractSLSsteam(){
        downloadSLSsteam
         7z x $SCRIPT_DIR/SLSsteam_Download/SLSsteam-Any.7z -aoa > /dev/null
         rm -rf tools
         rm -rf res
         rm setup.sh
         rm -rf docs
         rm SLSsteam-Any.7z
		 echo "SLSsteam Downloaded: Latest"
		 cd $InstallDir/
         }

    copySLSsteam(){
        extractSLSsteam
        wheresteamdir
        rm -rf $InstallDir
        }

    InstallSLSsteam(){
        echo "Installing SLSsteam..."
        if [ -d "$SLSsteamInstallDir" ]; then
          copySLSsteam
        else
            copySLSsteam
        fi
            echo "" &> /dev/null
        }
        
    whereCR_Install(){
       if [ -d "$FlatpakCloudRedirectDir" ]; then
               cd $FlatpakSteamInstallDir
        else
                cd $CloudRedirectDir
            fi
                echo "" &> /dev/null
                }
    
    crinstall(){
      if crconfigcheck; then
        echo "Downloading Latest Cloud Redirect Library"
        whereCR_Install
		 echo "Installing Cloud Redirect App"
		    flatpak remote-add --user --if-not-exists cloudredirect $cloudredirect
		    flatpak remote-add --user --if-not-exists flathub $flathub
		    flatpak --user update --appstream --noninteractive
		    flatpak install --user flathub org.kde.Platform//6.10 --assumeyes --noninteractive
		    flatpak install --user --reinstall org.cloudredirect.CloudRedirect --assumeyes --noninteractive
		    update-desktop-database
        wget -O cloud_redirect.so "$CloudRedirectLib" &> /dev/null
        echo "Latest Cloud Redirect Library Downloaded"
      else
        echo "User Is Not Using Cloud Redirect Skipping.."
      fi
        echo "" &> /dev/null
        }
        
        
    editconfig(){
        whereSLSsteamconfig
            if [ -f .headcrabd ]; then
                echo "Headcrab Config Found Skipping Changes"
            else
                sed -i "s/^PlayNotOwnedGames:.*/PlayNotOwnedGames: yes/" config.yaml
                sed -i "s/^SafeMode:.*/SafeMode: yes/" config.yaml
				sed -i "s/^NotifyInit:.*/NotifyInit: yes/" config.yaml
				sed -i "s/^Notifications:.*/Notifications: yes/" config.yaml
				echo "config patched" > .headcrabd
            fi
            }

    createsteamcfg(){
    wheresteamcfg
    if [ -f "steam.cfg" ]; then
        echo "steam.cfg Found Skipping Creation Process.."
    else
        cat << 'EOF' > steam.cfg
BootStrapperInhibitAll=enable
BootStrapperForceSelfUpdate=disable
EOF
    fi
        echo "" &> /dev/null
    }

    patchsteam(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                patchflatpaksteam
        else
                patchlocalsteam
        fi
        }
        
    checkcrsteam(){
      if crconfigcheck; then
        echo "Fetching Headcrab-CR Client"
        cd $SteamInstallDir/
        rm steam.sh
        wget -O steam.sh "$Headcrab_Native_CR" &> /dev/null
        echo "Patched Client With Headcrab-CR"
      else
        echo "Fetching Headcrab Client"
        cd $SteamInstallDir/
        rm steam.sh
        wget -O steam.sh "$Headcrab_Native" &> /dev/null
        echo "Patched Client With Headcrab"
      fi
        echo "" &> /dev/null
        }
        
    checkcrflatpaksteam(){
      if crconfigcheck; then
        echo "Fetching Headcrab-CR Client"
        cd $FlatpakSteamInstallDir/
        rm steam.sh
        wget -O steam.sh "$Headcrab_Flatpak_CR" &> /dev/null
        echo "Patched Client With Headcrab-CR"
      else
        echo "Fetching Headcrab Client"
        cd $FlatpakSteamInstallDir/
        rm steam.sh
        wget -O steam.sh "$Headcrab_Flatpak" &> /dev/null
        echo "Patched Client With Headcrab"
      fi
        echo "" &> /dev/null
        }
        
    patchflatpaksteam(){
        cd $FlatpakSteamInstallDir/
        wget -O client.sh "$Headcrab_Client" &> /dev/null
            chmod 777 steam.sh
            checkcrflatpaksteam
            chmod 555 steam.sh
			chmod +x client.sh
            echo "SLSSteamInstallType: Flatpak"
        }

    patchlocalsteam(){
        cd $SteamInstallDir/
        wget -O client.sh "$Headcrab_Client" &> /dev/null
        chmod 777 steam.sh
			checkcrsteam
			chmod 555 steam.sh
			chmod +x client.sh
        	echo "SLSsteamInstallType: Native"
        }

    checkcrstatus(){
        if crconfigcheck; then
            echo "CloudRedirectStatus: Enabled"
        else
            echo "CloudRedirectStatus: Disabled"
        fi
            echo "" &> /dev/null
            }

        conditioncheck(){
            crinstall
            echo "Checking Conditions.."
            echo "=================================================="
            editconfig
            patchsteam
            echo "BlockedClientUpdates: Enabled"
            checkcrstatus
            echo "=================================================="
            }

    main(){
        preinstallchecks
		SetupHeadcrab_Updater
        checkforsteamcfg
        }

    main
