---
* z or zoxide (cd) - A smarter cd command for navigating your filesystem.
* eza (ls) - A modern replacement for `ls` with more features and better defaults.
* bat (cat) - A cat clone with syntax highlighting and Git integration.
* fzf - A general-purpose command-line fuzzy finder.
* tv (television) - General purpose fuzzy finder TUI https://github.com/alexpasmantier/television
* delta - A viewer for git and diff output.
* fd - A simple, fast and user-friendly alternative to 'find'.
* tldr - Simplified and community-driven man pages.
* btop - A resource monitor that shows usage and stats for processor, memory, disks, network & processes.
* soulver - Standalone cli for the Soulver calculation engine - https://github.com/soulverteam/Soulver-CLI
* monolith - CLI tool for saving complete web pages as a single HTML file https://github.com/Y2Z/monolith

Find more in [file:///Users/bryan/bin/setup/homebrew/README-fav-cli-tools.md]
---
###
Above here are the ones I'm learning to use and display on login.
Display above this line in .bash_profile with
```awk '/###/{exit}1' "$HOME/bin/setup/homebrew/README-fav-cli-tools.md"```

# Additional tools

* ripgrep - A line-oriented search tool that recursively searches your current directory for a regex pattern.
* yadm - A tool for managing dotfiles.
* direnv - An environment switcher for the shell.
* thefuck - Corrects errors in previous console commands.
* wget - A network utility to retrieve files from the web.
* tmux - A terminal multiplexer that allows multiple terminal sessions to be accessed simultaneously.
* tree - A recursive directory listing command that produces a depth-indented listing of files. Use exa instead.
* less # Pager program similar to more (1) but with support for windows and binary files https://www.greenwoodsoftware.com/less/
* s-search # Web search from the terminal https://github.com/zquestz/s
* youtube-dl # Download YouTube videos from the command-line https://youtube-dl.org/
* tesseract # OCR (Optical Character Recognition) engine https://github.com/tesseract-ocr/

# PDF tools

* diff-pdf # Visually compare two PDF files https://vslavik.github.io/diff-pdf/
* pdfgrep # Search PDFs for strings matching a regular expression https://pdfgrep.org/
* poppler # PDF rendering library (based on the xpdf-3.0 code base) https://poppler.freedesktop.org/
* jpdfbookmarks # Create and edit bookmarks on existing PDF files https://sourceforge.net/projects/jpdfbookmarks/

# File Management

* rmlint - Tool to find and remove duplicate files and other lint from your filesystem.
* rsync # Utility that provides fast incremental file transfer https://rsync.samba.org/
* rclone - A command-line program to manage files on cloud storage. https://rclone.org/
* ncdu - A disk usage analyzer with an ncurses interface.
* ntfy - A utility for sending notifications from the command line. TODO: to INSTALL
* mc - A visual file manager, inspired by Norton Commander.
* rsync-time-backup # Time Machine-style backup for the terminal using rsync https://github.com/laurent22/rsync-time-backup
* duck # Command-line interface for Cyberduck (a multi-protocol file transfer tool) https://duck.sh/ (can be scripted)
* mas # Install App Store command line tools https://github.com/mas-cli/mas

# Development

* jq - A lightweight and flexible command-line JSON processor.
* entr - A utility for running arbitrary commands when files change.
* fswatch # Monitor a directory for changes and run a shell command https://github.com/emcrisostomo/fswatch

# Network tools

* nethogs - groups bandwidth by process. [raboof/nethogs: Linux 'net top' tool](https://github.com/raboof/nethogs)
* nmap - A network exploration tool and security/port scanner.
* tcpdump - A powerful command-line packet analyzer.
* iperf3 - A tool for measuring maximum TCP and UDP bandwidth performance.
* speedtest_cli # Command-line interface for https://speedtest.net bandwidth tests https://

# Web tools

* httpie -  httpie # HTTP client for the terminal https://httpie.org/
* monolith - CLI tool for saving complete web pages as a single HTML file https://github.com/Y2Z/monolith
* atac - Simple API client (Postman-like) in your terminal https://atac.julien-cpsn.com/

Example monolith command
monolith https://college.harvard.edu/admissions/apply/first-year-applicants/considering-gap-year -i -s -v -j -F -o considering-gap-year4.html
-i - remove images
-v - remove videos
-j - remove javascript
-F - remove web fonts - this can be lots of space!
-o - output file
-s - quiet

# Fun

* cmatrix - A terminal-based "The Matrix" like screen saver.
