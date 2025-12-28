#!/usr/bin/env bash
set -eu

    #paths
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
    SteamInstallDir=$HOME/.steam/steam
    SLSsteamInstallDir=$HOME/.local/share/SLSsteam
    SLSsteamConfigDir=$HOME/.config/SLSsteam
    InstallDir=$SCRIPT_DIR/bin
    RepoSLSsteamLocation=/usr/lib32

    HASHFETCH=https://raw.githubusercontent.com/AceSLS/SLSsteam/refs/heads/main/res/updates.yaml

    checkforsteamcfg(){
    cd $SteamInstallDir/
    if [ -f "steam.cfg" ]; then
        rm steam.cfg
        killall steam || true
        echo "the headcrab approaches.."
        echo "the headcrab lactches on the steam process.."
        export_sls steam steam://exit &> /dev/null
    else
        export_sls steam steam://exit &> /dev/null
    fi
        conditioncheck
        }


    downloadSLSsteam(){
        echo "Downloading Latest SLSsteam.."
        cd $SCRIPT_DIR/
        wget $HASHFETCH
        wget -O SLSsteam-Any.7z \
    $(curl -s "https://api.github.com/repos/AceSLS/SLSsteam/releases/latest" \
    | grep "browser_download_url" \
    | grep "SLSsteam-Any.7z" \
    | cut -d '"' -f 4)
    }
    export_sls(){
        if [ -f "$RepoSLSsteamLocation/libSLSsteam.so" ]; then
                echo "Using Repo Location"
                LD_AUDIT=$RepoSLSsteamLocation/libSLS-library-inject.so:$RepoSLSsteamLocation/libSLSsteam.so "$@"
        else
                copySLSsteam
                LD_AUDIT=$HOME/.local/share/SLSsteam/library-inject.so:$HOME/.local/share/SLSsteam/SLSsteam.so "$@"
                fi
                }

    extractSLSsteam(){
        downloadSLSsteam
         7z x $SCRIPT_DIR/SLSsteam-Any.7z -aoa
         rm -rf tools
         rm -rf res
         rm setup.sh
         rm -rf docs
         rm SLSsteam-Any.7z
         mv updates.yaml $SLSsteamConfigDir/
         echo "SLSsteam Downloaded: Latest"
         }

    copySLSsteam(){
        extractSLSsteam
        mkdir -p $SLSsteamInstallDir
        cp $InstallDir/library-inject.so $SLSsteamInstallDir/
        cp $InstallDir/SLSsteam.so $SLSsteamInstallDir/
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

        Purgepreviousversion(){
        echo "Purging Previous Version"
        cd $SLSsteamInstallDir
        if [ -f "$SLSsteamInstallDir/SLSsteam.so" ]; then
          rm SLSsteam.so
        else
           echo "" &> /dev/null
        fi
            echo "" &> /dev/null
        }

    backupconfig(){
        purgeoldhash
        cd $SLSsteamConfigDir/
        if [ -f "config.yaml" ]; then
            mv config.yaml config.yaml.bak
    else
            echo "" &> /dev/null
        fi
            echo "" &> /dev/null
            }

            purgeoldhash(){
        cd $SLSsteamConfigDir/
        if [ -f "updates.yaml" ]; then
            rm updates.yaml
    else
            echo "" &> /dev/null
        fi
            echo "" &> /dev/null
            }

    editconfig(){
        cd $SLSsteamConfigDir/
            if grep -q -F "PlayNotOwnedGames: no" "config.yaml"; then
                sed -i "s/^PlayNotOwnedGames:.*/PlayNotOwnedGames: yes/" config.yaml
                echo "PlayNotOwnedGames: Enabled"
            else
                echo "PlayNotOwnedGames: Enabled"
                fi
            }

    createsteamcfg(){
    cd $SteamInstallDir/
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
        Purgepreviousversion
        checkforsteamcfg
        }

    main






