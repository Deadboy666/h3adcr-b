#!/usr/bin/env bash
set -eu

    #Headcrab Compatibile Client Version
    HeadcrabCompatibleClientVer=1769025840
    
    #Paths
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
	ApplicationDirectory=$HOME/.local/share/applications
    SteamInstallDir=$HOME/.steam/steam
    FlatpakSteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.steam/steam
    FlatpakSLSsteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam
    FlatpakSLSsteamConfigDir=$HOME/.var/app/com.valvesoftware.Steam/.config/SLSsteam
    SLSsteamInstallDir=$HOME/.local/share/SLSsteam
    SLSsteamConfigDir=$HOME/.config/SLSsteam
    InstallDir=$SCRIPT_DIR/bin
    Headcrab_Downgrader_Path=$HOME/.headcrab
	
	#URL'S
    Headcrab_Downgrade_URL="http://localhost:1666/"
	LinuxClientManifest="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/steam_client_ubuntu12"
    DeckClientManifest="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/steam_client_steamdeck_stable_ubuntu12"
	Steamos_Native_LaunchScript="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/steam.sh"
    dgsc="https://github.com/Deadboy666/h3adcr-b/raw/refs/heads/testing/dgsc"
    dlm="https://github.com/Deadboy666/h3adcr-b/raw/refs/heads/testing/dlm"
    Sources="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/sources.txt"
	Headcrab_Updater="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/headcrab.desktop"
	
    archcheck() {  
		[ -f /etc/os-release ] && source /etc/os-release ]
		if ! grep -q "^ID_LIKE=" /etc/os-release || echo "ID_LIKE=arch" | sudo tee -a /etc/os-release > /dev/null
	    fi
	    	[ -f /etc/os-release ] && . /etc/os-release && [[ "$ID" == "arch" || "$ID" == "cachy" || "$ID_LIKE" =~ "arch" ]]
	}

    debiancheck(){
        [ -f /etc/os-release ] && source /etc/os-release && [[ "${ID:-}" == "debian" || "${ID:-}" == "ubuntu" || "${ID_LIKE}" =~ "debian" || "${ID_LIKE}" =~ "ubuntu" ]]
        }   

    steamoscheck(){
        [ -f /etc/os-release ] && source /etc/os-release && [ "${ID:-}" = "steamos" ]
        }
    
    flatpakcheck(){
        [ -d "$FlatpakSteamInstallDir" ]
        }
		
	SetupHeadcrab_Updater(){
	cd $ApplicationDirectory/
	wget "$Headcrab_Updater" &> /dev/null
	chmod +x headcrab.desktop
	update-desktop-database $ApplicationDirectory
	echo "Headcrab Updater Now In Your Applications Menu"
	echo "Can Open Up Headcrab Updater To Update To Latest Version."
	}
        
    SteamOSClientCheck(){
        if [ -f "steam_client_steamdeck_stable_ubuntu12.manifest" ]; then
            versionnumber=$(grep '"version"' steam_client_steamdeck_stable_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Stable"
        else
            versionnumber=$(grep '"version"' steam_client_steamdeck_publicbeta_ubuntu12.manifest | awk -F'"' '{print $4}')
            echo "SteamClientChannel: Beta"
        fi
            echo "SteamClientType: SteamOS"
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

    CheckClientInfo(){
        echo "SteamClientInfo:"
        wheresteamcfg
        cd package/
        if steamoscheck; then
            SteamOSClientCheck
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
        installdebiandeps
        removearchpkg
        }

    installdebiandeps() {	    
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

    removearchpkg(){
        if archcheck; then
        installed_pkgs=$(pacman -Qq | grep -E '^slssteam(-git)?$' || true)
        if [ -n "$installed_pkgs" ]; then
            echo "We need to convert your Arch SLSsteam installation to a local one."
            echo "Uninstalling Arch packages: $installed_pkgs"
            sudo pacman -Rns --noconfirm $installed_pkgs
        fi
        fi
    }
    
    DownloadClientManifest(){
        if steamoscheck; then
        echo "Headcrab Downloading Steamos Client Manifest.."
        wget "$DeckClientManifest" &> /dev/null
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
        wheresteamcfg
        cd package/
        $Headcrab_Downgrader_Path/dlm --input-file sources.txt --max-concurrent 16
        echo "Headcrab_dlm Fetched Client Update"
        }
        
    dgsc(){
        download_dgsc
        echo "Running Headcrab_dgsc.."
        wheresteamcfg
        cd package/
        $Headcrab_Downgrader_Path/dgsc --port 1666 --silent & sleep 1s "$@"
        }
        
    prepdowngrade(){
        wheresteamcfg
        rm package/*
        cd package/
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
        elif flatpakcheck; then
            echo "Headcrab Bootstrapping SLSsteam.."
            export_sls wheresteam -clearbeta steam://exit
		else
			export_sls wheresteam -clearbeta steam://exit
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
                flatpak run com.valvesoftware.Steam "$@"
        else
                steam "$@"
            fi
                echo "" &> /dev/null
            }
            
    wheresteamdir(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                mkdir -p $FlatpakSLSsteamInstallDir
                cp -f $InstallDir/library-inject.so $FlatpakSLSsteamInstallDir/
                cp -f $InstallDir/SLSsteam.so $FlatpakSLSsteamInstallDir/ 
        else
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
        if steamoscheck; then
            echo "Steamos Detected"
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
    if [ -f "steam.cfg" ]; then
        rm steam.cfg
    else
        echo "No Pre Exisiting Steam.cfg"
    fi
        nuketheclient
        CheckHeadcrabCompatibility
        conditioncheck
        }


    downloadSLSsteam(){
        echo "Downloading Latest SLSsteam.."
        cd $SCRIPT_DIR/
        wget -O SLSsteam-Any.7z \
    $(curl -s "https://api.github.com/repos/AceSLS/SLSsteam/releases/latest" \
    | grep "browser_download_url" \
    | grep "SLSsteam-Any.7z" \
    | cut -d '"' -f 4) &> /dev/null
    }
    
    export_sls(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                copySLSsteam
                LD_AUDIT=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/library-inject.so:$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/SLSsteam.so "$@"
        else
                copySLSsteam
                LD_AUDIT=$HOME/.local/share/SLSsteam/library-inject.so:$HOME/.local/share/SLSsteam/SLSsteam.so "$@"
        fi
                echo "" &> /dev/null
                }

    extractSLSsteam(){
        downloadSLSsteam
         7z x $SCRIPT_DIR/SLSsteam-Any.7z -aoa > /dev/null
         rm -rf tools
         rm -rf res
         rm setup.sh
         rm -rf docs
         rm SLSsteam-Any.7z
         echo "SLSsteam Downloaded: Latest"
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
            backupconfig
        }

    plsdontbreakthingsthatwork(){
        whereSLSsteamconfig
        if [ -f "config.bak" ]; then
            mv config.bak config.yaml
    else
            echo "" &> /dev/null
        fi
            echo "" &> /dev/null
            }
            
    backupconfig(){
        plsdontbreakthingsthatwork
        if [ -f "config.yaml" ]; then
            mv config.yaml config.yaml.bak
    else
            echo "" &> /dev/null
        fi
            echo "" &> /dev/null
            }

    editconfig(){
        whereSLSsteamconfig
            if grep -q -F "PlayNotOwnedGames: no" "config.yaml"; then
                sed -i "s/^PlayNotOwnedGames:.*/PlayNotOwnedGames: yes/" config.yaml
                sed -i "s/^SafeMode:.*/SafeMode: no/" config.yaml
                echo "PlayNotOwnedGames: Enabled"
                echo "SafeMode: Enabled"
            else
                echo "PlayNotOwnedGames: Enabled"
                echo "SafeMode: Enabled"
                fi
            }

    createsteamcfg(){
    wheresteamcfg
    if [ -f "steam.cfg" ]; then
        rm steam.cfg
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

        
    patchflatpaksteam(){
        cd $FlatpakSteamInstallDir/
        if grep -q -F "export LD_AUDIT=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/library-inject.so:$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/SLSsteam.so" "steam.sh"; then
            echo  "Steam Runner Script Already Patched ,Skipping..."
        else
            sed -i '10a export LD_AUDIT=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/library-inject.so:$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam/SLSsteam.so' steam.sh
        fi
            echo "SLSSteamInstallType: Flatpak"
        }

    patchlocalsteam(){
        cd $SteamInstallDir/
        if [ -f "steam.sh" ]; then
            mv steam.sh steam.sh.bak
        	wget "$Steamos_Native_LaunchScript" &> /dev/null
			chmod +x steam.sh
		fi
        	echo "SLSSteamInstallType: Local"
        }

        conditioncheck(){
            echo "Checking Conditions..."
            patchsteam
            echo "BlockedClientUpdates: Enabled"
            editconfig
            echo "HeadcrabStatus: Patched"
            }

    main(){
        preinstallchecks
		SetupHeadcrab_Updater
        backupconfig
        checkforsteamcfg
        }

    main






