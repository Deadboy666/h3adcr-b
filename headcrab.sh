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
                cp $InstallDir/library-inject.so $FlatpakSLSsteamInstallDir/
                cp $InstallDir/SLSsteam.so $FlatpakSLSsteamInstallDir/ 
        else
                 mkdir -p $SLSsteamInstallDir
                 mkdir -p $SLSsteamConfigDir
                 cp $InstallDir/library-inject.so $SLSsteamInstallDir/
                 cp $InstallDir/SLSsteam.so $SLSsteamInstallDir/
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
        export_sls wheresteam steam://exit &> /dev/null
    else
        export_sls wheresteam steam://exit &> /dev/null
    fi
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

    backupconfig(){
        whereSLSsteamconfig
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
                sed -i "s/^SafeMode:.*/SafeMode: yes/" config.yaml
                sed -i "/FakeAppIds:/a\\  0: 480" config.yaml
                echo "PlayNotOwnedGames: Enabled"
                echo "FakeAppIdGlobal: Enabled"
                echo "SafeMode: Enabled"
            else
                echo "PlayNotOwnedGames: Enabled"
                echo "FakeAppIdGlobal: Enabled"
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
        checkforsteamcfg
        }

    main






