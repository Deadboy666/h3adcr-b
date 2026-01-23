#!/usr/bin/env bash
set -eu

    #paths
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
    SteamInstallDir=$HOME/.steam/steam
    FlatpakSteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.steam/steam
    FlatpakSLSsteamInstallDir=$HOME/.var/app/com.valvesoftware.Steam/.local/share/SLSsteam
    FlatpakSLSsteamConfigDir=$HOME/.var/app/com.valvesoftware.Steam/.config/SLSsteam
    SLSsteamInstallDir=$HOME/.local/share/SLSsteam
    SLSsteamConfigDir=$HOME/.config/SLSsteam
    InstallDir=$SCRIPT_DIR/bin
    RepoSLSsteamLocation=/usr/lib32
    ClientManifest="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/steam_client_ubuntu12"
    Headcrab_Downgrade_URL="http://localhost:1666/"
    Headcrab_Downgrader_Path=$HOME/.headcrab
    dgsc="https://github.com/Deadboy666/h3adcr-b/raw/refs/heads/testing/dgsc"
    Sources="https://raw.githubusercontent.com/Deadboy666/h3adcr-b/refs/heads/testing/sources.txt"
    
    download_dgsc(){
        mkdir -p $Headcrab_Downgrader_Path
        cd $Headcrab_Downgrader_Path/
        if [ -f "$Headcrab_Downgrader_Path/dgsc" ]; then
            echo "Headcrab_dgsc Downloaded Already."
        else
            echo "Downloading Headcrab_dgsc.."
            wget "$dgsc"
            chmod +x dgsc
        fi
          echo "" &> /dev/null
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
        wget "$ClientManifest" &> /dev/null
        echo "Fetching Client Update With Headcrab.."
        cat sources.txt | while read line;
do
    wget "$line"
done
    dgsc
        }
        
    clientdowngrade(){
        prepdowngrade
        checkforsteamcfg
        }
        
        
    wheresteam(){
        if [ -d "$FlatpakSteamInstallDir" ]; then
                com.valvesoftware.Steam "$@"
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
            
    checkforsteamcfg(){
    wheresteamcfg
    if [ -f "steam.cfg" ]; then
        rm steam.cfg
        killall wheresteam || true
        echo "the headcrab approaches.."
        echo "the headcrab lactches on the steam process.."
        export_sls wheresteam -clearbeta -textmode -forcesteamupdate -forcepackagedownload -overridepackageurl "$Headcrab_Downgrade_URL" -exitsteam &> /dev/null
    else
        export_sls wheresteam -clearbeta -textmode -forcesteamupdate -forcepackagedownload -overridepackageurl "$Headcrab_Downgrade_URL" -exitsteam &> /dev/null
    fi
        killall dgsc
        conditioncheck
        }


    downloadSLSsteam(){
        echo "Downloading Latest SLSsteam.."
        cd $SCRIPT_DIR/
        wget -O SLSsteam-Any.7z \
    $(curl -s "https://api.github.com/repos/AceSLS/SLSsteam/releases/latest" \
    | grep "browser_download_url" \
    | grep "SLSsteam-Any.7z" \
    | cut -d '"' -f 4)
    }
    
    export_sls(){
        if [ -f "$RepoSLSsteamLocation/libSLSsteam.so" ]; then
        
                LD_AUDIT=/usr/lib32/libSLS-library-inject.so:/usr/lib32/libSLSsteam.so "$@"
        elif [ -d "$FlatpakSteamInstallDir" ]; then
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
         7z x $SCRIPT_DIR/SLSsteam-Any.7z -aoa
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
        echo "BlockedClientUpdates: Enabled"
    }

    patchsteam(){
        if [ -f "$RepoSLSsteamLocation/libSLSsteam.so" ]; then
                patchreposteam
        elif [ -d "$FlatpakSteamInstallDir" ]; then
                patchflatpaksteam
        else
                patchlocalsteam
        fi
        }

    patchreposteam(){
        cd $SteamInstallDir/
        if grep -q -F "export LD_AUDIT=/usr/lib32/libSLS-library-inject.so:/usr/lib32/libSLSsteam.so" "steam.sh"; then
            echo  "Steam Runner Script Already Patched ,Skipping..."
        else
            sed -i '10a export LD_AUDIT=/usr/lib32/libSLS-library-inject.so:/usr/lib32/libSLSsteam.so' steam.sh
        fi
            echo "SLSSteamInstallType: System"
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
        if grep -q -F "export LD_AUDIT=$HOME/.local/share/SLSsteam/library-inject.so:$HOME/.local/share/SLSsteam/SLSsteam.so" "steam.sh"; then
            echo "Steam Runner Script Already Patched ,Skipping..."
        else
            sed -i '10a export LD_AUDIT=$HOME/.local/share/SLSsteam/library-inject.so:$HOME/.local/share/SLSsteam/SLSsteam.so' steam.sh
        fi
            echo "SLSSteamInstallType: Local"
        }

        conditioncheck(){
            echo "Checking Conditions..."
            editconfig
            createsteamcfg
            patchsteam
            echo "HeadcrabStatus: Patched"
            }

    main(){
        backupconfig
        clientdowngrade
        }

    main






