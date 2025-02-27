#!/usr/bin/env bash

# this script installs all my app store apps.  Useful for new machine set up.

# mas is a command line client to the App Store
# see https://github.com/mas-cli/mas

# common commands
# mas list - list your installed apps
# mas search <app name> - to find an app identifier
# in app store the id is 1607635845 from the url https://apps.apple.com/nz/app/velja/id1607635845?mt=12

# Install mas - Mac App Store command-line interface
masInstall() {
    if command -v mas >/dev/null; then
        printf "%s\n" "Already up-to-date."
    else
        printf "%s\n" "Getting mas-cli - a simple command line interface for the Mac App Store."
        brew install mas
    fi
}
masInstall

#mas install 567704457 # OmniPopLite (3.2)
#mas install 409183694 # Keynote (7.0)
#mas install 409201541 # Pages (6.0)
#mas install 409203825 # Numbers (4.0)
#mas install 456362093 # MuteMyMic (1.10)
#mas install 484388250 # Numi (1.7.7) # now done with brew
#mas install 784801555 # Microsoft OneNote (15.27.1)
mas install 560846814 # PDF Converter Master (4.0.0)
#mas install 896450579 # Textual (6.0.2) # TODO figure out if still in app store
mas install 453114608 # JSON Helper (1.07)
#mas install 682658836 # GarageBand (10.1.2)
#mas install 488536386 # Location Helper (1.02)
#mas install 700757313 # Halloween Fonts (4.0)
#mas install 883878097 # Server (5.2) # seems to be no longer offered by Apple
#mas install 431511738 # Timing (1.7.4) # installed by brew now
mas install 465965038 # Markdown Pro (1.0.9)
#mas install 607997198 # Marko (2.1)
mas install 586862299 # Duplicate Cleaner For iPhoto (1.13)
#mas install 497799835 # Xcode (8.0)
#mas install 491365225 # OneClickdigital (1.12) # no longer used; likely not available
# mas install 413965349 # Soulver (2.6.0)
mas install 408981434 # iMovie (10.1.2)  # TODO figure out why this doesn't install
#mas install 424389933   # Final Cut Pro
mas install 594444151 # PDF to JPG (4.0)
#mas install 555935825 # Themes for Keynote Free (2.2)
mas install 929188617 # Timeline 3D (5.1.2)
#mas install 715394237 # Condense (1.61)
#mas install 935700987 # Snapselect (1.3.0) # no longer available
#mas install 615916400 # BrowseShot (1.0)
#mas install 511648940 # Metanota
#mas install 406056744 # Evernote
#mas install 412980789 # Full Deck Solitaire
#mas install 692867256 # Simplenote
# mas install 410801088 # Wallpaper Wizard # no longer works well or seems to be available
#mas install 426397771 # SQLVue
mas install 456624497 # Brightness Slider
# mas install 445189367 # PopClip # use Maccy now; no longer seems available
#mas install 6462355119 # OwlOCR - Screenshot to Text (6.0.6) # done with brew now
#mas install 883878097 # Server
#mas install 576421334 # Converto
#mas install 467939042 # Growl
#mas install 760246983 # Free Fonts - Christmas Collection
#mas install 512556651 # Solve
mas install 414568915 # Key Codes
#mas install 528459889 # TuneSpan
#mas install 525517698 # TextSoapMenu-MAS
mas install 512464723 # Alinof Timer
mas install 593913958 # Expresso - text calculator
#mas install 409789998 # Twitter
mas install 525912054 # WiFi Signal
#mas install 415492014 # Inpaint 
#mas install 503729945 # SizzlingKeys (5.1.4)
mas install 549083868 # Display Menu (2.2.2)
#mas install 688211836 # EasyRes (1.1.1) # use BetterDisplay now; no longer seems available
mas install 1274495053  # Microsoft To Do  ## NOT WORKING; TODO try to fix
mas install 1295203466 # Microsoft Remote Desktop

#mas install 1607635845 # Velja (1.10.1) - browser picker: Open links in a specific browser or a matching native app. Easily switch between browsers # done with brew now
mas install 1377973524 # Sandkorn (1.8.2) - shows you what entitlements those apps - [Sandkorn - Peter Borg Apps](https://www.peterborgapps.com/sandkorn/)
mas install 425264550  # Blackmagic Disk Speed Test (3.4.2)
mas install 937984704  # Amphetamine                    (5.2.2) - keep-awake utility

mas install 1136220934 # Infuse • Video Player        (7.4.6); works with Plex and NAS

mas install 1457744893 # EmojiFinder: search emoji (2.2.5)

mas install 1289197285 # MindNode – Mind Map & Outline  (2022.4.3); nice simple mindmapping tool

mas install 1510445899 # Meeter for Zoom, Teams & Co       (1.1.3) https://www.bardeen.ai/meeter; menu item for launching video calls

mas install 1115567069  # Health Auto Export - export and manage your health data

mas install 1545870783  # Color Picker - menu bar color picker
mas install 413897608  # Pastel - Beautiful color palettes

mas install 1499215709  # Pasteboard Viewer # view clipboard history
mas install 1527716894  # Webp Converter - convert Webp images to PNG or JPG
mas install 1612708557 # Scaler - Scaler is a bandwidth monitor app for your macOS device. It shows you your current network speed in the menu bar and provides detailed information about your data usage for the past 30 days. [0.0]

#mas install 1487406555  # Safari extension Tab Count # no longer available
mas install 1515213004  # Session Pal - Safari session manager
mas install 1569813296  # 1Password for Safari

mas install 1487937127  # Craft: Write notes, AI editing 2.5.5 [0.0]
mas install 1660147028 # Amazing AI - Generate images from text using Stable Diffusion
mas install 1569600264  # Pandan - Pandan is a time awareness tool, not a traditional time tracker or break reminder. It shows you how long you have been actively using your computer, to make you aware and let you decide when it's time to take a break. 

mas install 381059732 # WeekCal
mas install 512464723  # AS Timer - easy to use timer; I tend to use raycast's built in timer now

mas install 6444667067  # Hyperduck - Send links from iOS to a Mac; works better than air drop, works in any app, better than handoff
#mas install 472717129  # Type2Phone - Hyperduck likely is better

mas install 1522267256 # Shareful - Shareful makes the system share menu even more useful by providing some commonly needed share services

mas install 876529098   # StockSpy Realtime Stocks Quote
mas install 973213640   # MSG Viewer for Outlook
mas install 545519333  # Prime Video

# Brainfever image apps [BrainFeverMedia](http://www.brainfevermedia.com/index.html)
mas install 1468834161  # BrainFever
mas install 1557797120  # Infinite Skies  
# mas install 1468834161  # LensFlare Studio

 mas install 1132845904 # AppLocker • Passcode lock apps (1.6.0) Password protect secret apps

mas install 1547364831  # Blink: Eye Strain Reliever     (1.1)
mas install 1457158844  # Take a break - timer, reminder (1.7.1)

# wifi and network analyzers and speed testers
#mas install 1526841848 # yFi WiFi Companion (1.2) [yFi - stay connected to your WiFi](https://yfi.coderose.io/) - auto reconnects wifi when transfer rate is slow. # no longer seems available

mas install 1664371307 # Ultra Wifi - Analyzer, Monitor (2.1.0) # this one is the best!
mas install 1153157709 # Speedtest by Ookla                      (1.27)
mas install 1455463454 # WiFi Speed Test Tools                   (1.6.4)

mas install 302584613  # Amazon Kindle                                (6.86) replaces Kindle Classic app

mas install 1516950324 # Overlap by Moleskine Studio    (2.1.1) Timezone meeting planner - [Overlap by Moleskine Studio on the App Store](https://apps.apple.com/us/app/overlap-by-moleskine-studio/id1516950324)

mas install 1481005137 # Cloud Battery                   (4.41) Track battery level on all devices. Install on iOS too.

mas install 1294126402 # name: HEIC
mas install 897118787 # name: Shazam
mas install 897446215 # name: Canva
mas install 1477385213 # name: Save
mas install 1498912833 # name: Highlights
mas install 6502970995 # name: Taify
mas install 1099568401 # name: Home
mas install 1171820258 # name: Highland
mas install 490192174 # name: Battery
mas install 1112075769 # name: Pine
mas install 1351639930 # name: Gifski
mas install 6475956137 # name: Grab2Text
mas install 569048352 # name: Liquid
mas install 803453959 # name: Slack
mas install 1284863847 # name: Unsplash
mas install 6474268307 # name: Enchanted
mas install 1645016851 # name: Bluebook
mas install 1586435171 # name: Actions
mas install 461369673 # name: VOX
mas install 1502839586 # name: Hand
mas install 562211012 # name: Yomu
mas install 1179373118 # name: Reader
mas install 6469021132 # name: PDFgear
mas install 1611378436 # name: Pure

# mas install 540348655  # Monosnap - replaced by Shottr, but still a good app

#1611378436  Pure Paste (1.0.1) - paste without formatting # tried it but PopClip is better
#1586203406  Tabby

# mas install 521464274 # Farensius Desktop # seems to no longer be available

## Apps installed via casks now

# 411246225 Caffeine
# 503729945 SizzlingKeys
# 1094748271 FullContact
# 405399194 Kindle
# mas install 803453959 # Slack (2.0.3) ## NOT WORKING; TODO try to fix

## Apple apps

# 408981434 iMovie
# 408981381 iPhoto
# 424390742 Compressor
# 424389933 Final Cut Pro
# 409203825 Numbers
# 409183694 Keynote
# 409907375 Remote Desktop
# 682658836 GarageBand
# 634148309 Logic Pro X
# 409201541 Pages
# 408981426 Aperture
# 1127487414 Install macOS Sierra

## Apps no longer used

# 789738094 Scribe
# 412723606 mosaic - photo mosaic app
# 595553555 Backup Guru LE
# 911655829 Pixfeed # photo gallery for your social networks
# 919007298 Logo Pop Free
# 489880259 ScreenShot PSD
# 897118787 Shazam
# 458998390 Farensius
# 839495159 Toy Defense. World War I
# 451684583 Fireplace 3D
# 434433123 Apple Configurator
# 404035899 QuickCursor
# 439845554 Reeder
# 506622388 MDB Explorer
# 747482894 WebDAVNavServer
# 405580712 StuffIt Expander
# 605732865 RSS Bot
# 618111399 RSS Notifier
# 411227658 Shrook
# 928941247 OTP Manager
# 973134470 Pomodoro Time
# 865500966 feedly
# 408937559 iFlicks
# 568494494 Pocket
# 421337962 WeatherMan Lite
# 451424521 Rail Maze


# # Sindre Sorhus apps I've installed
# - [App Buddy — Sindre Sorhus](https://sindresorhus.com/app-buddy) - not an app store app; download it; for import/export settings from his apps
# - [Apps — Sindre Sorhus](https://sindresorhus.com/apps)
# - [AI Actions — Sindre Sorhus](https://sindresorhus.com/ai-actions)
# - [Pure Paste — Sindre Sorhus](https://sindresorhus.com/pure-paste)
# - [System Color Picker — Sindre Sorhus](https://sindresorhus.com/system-color-picker)
# - [Pasteboard Viewer — Sindre Sorhus](https://sindresorhus.com/pasteboard-viewer)
# - [Gifski — Sindre Sorhus](https://sindresorhus.com/gifski)
# - [HEIC Converter — Sindre Sorhus](https://sindresorhus.com/heic-converter)
# - [Actions — Sindre Sorhus](https://sindresorhus.com/actions)
