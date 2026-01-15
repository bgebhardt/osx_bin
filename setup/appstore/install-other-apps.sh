#!/bin/bash

# This script installs a list of apps from URLs.
# The following apps you'll have to get and install via there web installer

# * [FreeFileSync: Open Source File Synchronization & Backup Software](https://freefilesync.org/)
#   * [Download the Latest Version - FreeFileSync](https://freefilesync.org/download.php)
# * [Marked 2 - Smarter tools for smarter writers](https://marked2app.com/) - I bought from developer instead of Mac App Store
# * [alyssaxuu/later: Save all your Mac apps for later with one click 🖱️](https://github.com/alyssaxuu/later) - free app to save and restore open windows. Awesome!
# * [BuhoCleaner: The Best Mac Cleaner Optimized for M1/M2 Macs](https://www.drbuho.com/)
# * [Snail](https://snail.murusfirewall.com/) traffic shaping for MacOS
# * [WiFiRadar Pro | Wireless monitoring on steroids](https://wifiradar.app/)
# * [JSON Wizard | JSON, the easy way. For Mac.](https://jsonwizard.app/)
# * [Premium Fonts for Mac and Windows | MacAppware](https://macappware.com/software/mac-fonts/)
# * [Mac Font Manager Deluxe | MacAppware](https://macappware.com/software/mac-font-manager-deluxe/)
# * Clock - no cask; same software maker [seense | The Clock for macOS](https://seense.com/the_clock/)
# * Quick expose - no cask; same software maker [Quick Exposé: A New Way to Use Mission Control and App Exposé on macOS • MacPlus Software](https://noteifyapp.com/quick-expose/) 
# * Rapidweaver - download 9.1.1 from [RapidWeaver Release Notes](https://www.realmacsoftware.com/rapidweaver/releasenotes/) or [direct link](https://dl.devant.io/v1/3c53887f-427a-4af7-9144-ee16178c62f4/21049/RapidWeaver.zip)

# Function to download and install an app from a URL, detecting if it is a zip file
download_app() {
    local url=$1
    local app_name=$2
    local downloadName="$(basename "$url")"
    local download_dir="$HOME/Downloads"
    local localFilePath="$download_dir/$downloadName"

    echo "Downloading $app_name..."
    echo "  from $url"
    echo "  to $localFilePath"

    #curl -L -o ~/Downloads/FreeFileSync_13.9_macOS.zip https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip
    # curl -L -o "$localFilePath" "$url"
    open "$url" # opens the URL in the default browser and downloads the file to Downloads. Very fragile though.
}

# Function to download and install an app from a URL, detecting if it is a zip file
install_app() {
    local url=$1
    local app_name=$2
    local downloadName="$(basename "$url")"
    local download_dir="$HOME/Downloads"
    local localFilePath="$download_dir/$downloadName"

    if [[ $url == *.zip ]]; then
        echo "Unzipping $app_name..."
        #unzip -q "$localFilePath" -d "$download_dir/$app_name"
        unzip "$localFilePath"

        echo "Installing $app_name..."
        # copy app to /Applications or run the pkg installer
        #cp -r $download_dir/$app_name/*.app /Applications/
    else
        echo "Mounting $app_name.dmg..."
        hdiutil attach "$localFilePath" #-quiet

        # this didn't work or not well tested so just mounting for now.
        #echo "Installing $app_name..."
        #cp -r /Volumes/$app_name/*.app /Applications/

        #echo "Cleaning up..."
        #hdiutil detach "/Volumes/$app_name" #-quiet

        echo "Copy the application from the mounted DMG to /Applications manually. Then eject the disk image."
    fi

    #echo "Cleaning up..."
    #rm -rf $download_dir/$app_name*

    echo "$app_name installed successfully!"
}

# List of apps to install
apps=(
        "https://github.com/alyssaxuu/later/raw/master/Later.dmg Later"
    "https://www.drbuho.com/download/buhocleaner.dmg BuhoCleaner"
    "https://wifiradar.app/download WiFiRadar"
    "https://jsonwizard.app/download JSONWizard"
    "https://seense.com/the_clock/updateapp/the_clock.zip TheClock"
    "https://dl.devant.io/v1/3c53887f-427a-4af7-9144-ee16178c62f4/21049/RapidWeaver.zip RapidWeaver"
    #"https://downloads.thelasso.app/Lasso.dmg Lasso" # no done via brew

    # https://skylum.com/account/my-software
    "https://skylum.com/download/luminar-neo-m1-paid" LuminarNeo
    
    "https://www.peterborgapps.com/downloads/LingonPro10.zip Lingon Pro"

    "https://www.transcribex.io/download/TranscribeX.dmg TranscribeX"

    "https://wisprflow.onelink.me/PguH/lw5h199m WisprFlow"

    "https://noteifyapp.com/download/Tab%20Finder.zip Tab Finder"

    "https://launcher-desktop-updates.s3.us-west-2.amazonaws.com/1676216778768.Star%20Trek%20Fleet%20Command.dmg Star Trek Fleet Command"

    "https://mousepro.app/download Mouse Pro"

    "https://go.microsoft.com/fwlink/?linkid=2325438&clcid=0x409&culture=en-us&country=us Microsoft M365 Copilot"

    "https://updates.mailmate-app.com/archives/MailMateBeta.tbz MailMate"

    "https://www.macxdvd.com/download/macxvideo-ai.dmg MacXVideoAI"
    "https://www.macxdvd.com/download/macx-dvd-ripper-pro.dmg MacXDVDRipperPro"

    #"https://download.cisdem.com/cisdem-pdfconverterocr.dmg Cisdem PDF Converter OCR" # now down via brew
    "https://download.cisdem.com/cisdem-contactsmate.dmg Cisdem ContactsMate"

    "https://www.koingosw.com/products/getmirrorfile.php?path=%2Fproducts%2Fairradar%2Fdownload%2Fairradar.dmg AirRadar"

    # APPS WITH VERSION NUMBERS HARDCODED

    # "https://freefilesync.org/download.php FreeFileSync" # go to this link for latest version; hardcoded version for now
    "https://freefilesync.org/download/FreeFileSync_14.6_macOS.zip FreeFileSync"

    # Drive Thru RPG site https://legacy.drivethrurpg.com/library_client.php
    # "https://dtrpg-library-app.s3.us-east-2.amazonaws.com/DriveThruRPG_3.4.6.dmg" DriveThruRPG # now done via brew

    "https://bundlehunt-files.s3.us-west-2.amazonaws.com/2024-downloads/KeyKeeper-2.7.0.dmg.zip KeyKeeper"
    "https://ensili.co/download/colorhound/colorhound-1.5.zip Color Hound"

    "https://www.mabasoft.net/downloads/files/World_Clock_Deluxe_4.19.3.dmg" World_Clock_Deluxe
    
    "https://ensili.co/download/textilicious/textilicious-1.2.zip Textilicious"

    "https://www.anthropics.com/smartphotoeditor/downloads/1.33.4/SmartPhotoEditorTrialSetup64.pkg Smart Photo Editor"

    "https://cdn.ensili.co/download/qrwizard/qrwizard-2.6.zip QRWizard"

    "https://www.anthropics.com/portraitprobody/downloads/3.7.3/PortraitProBodyTrialSetup64.pkg PortraitProBody"

    "https://www.anthropics.com/portraitpro/downloads/24.3.2/PortraitProTrialSetup64.pkg PortraitPro"

    "https://fbreader.org/static/packages/macos/FBReader-2.1.3.dmg FBReader"

    "https://notes.granola.ai/download Granola"

    # Autoswitch between function and special keys. [How FNable works, the FN key toggle to switch Function Keys | FNable](https://fnable.com/en/howItWorks.html)
    "https://fnable.com/files/FNable.dmg FNable"
    
    # Missing apps
    # Peakto - [Media Asset Management Software for Visual Creators | Peakto](https://cyme.io/en/products/peakto/)
    
    # apps I no longer install
    #"https://noteifyapp.com/download/QuickExpose.zip QuickExpose"
    #"https://marked2app.com/download/ Marked2"
    #"https://github.com/TheMurusTeam/Snail/releases/download/v3.0/snail-3.0.zip Snail"
    #"https://macappware.com/software/mac-fonts/download MacFonts" not working
    #"https://macappware.com/software/mac-font-manager-deluxe/download MacFontManagerDeluxe" not working
)

# two apps to test with
test_apps=(
    # "https://freefilesync.org/download.php FreeFileSync" # go to this link for latest version
    # hardcoded version for now
    "https://freefilesync.org/download/FreeFileSync_13.9_macOS.zip FreeFileSync"
    "https://jsonwizard.app/download JSONWizard"
)

echo "This script will download apps by opening the url in your default browser. This is likely to be fragile."

# echo "This script will download the following apps:"
# for app in "${apps[@]}"; do
#     IFS=' ' read -r url name <<< "$app"
#     echo "  - $name"
# done

# Install each app
#for app in "${test_apps[@]}"; do
for app in "${apps[@]}"; do
    IFS=' ' read -r url name <<< "$app"
    download_app $url $name
    # TODO: Currently does not try installing. Just downloading.
    #install_app $url $name
done

echo "All apps installed successfully!"