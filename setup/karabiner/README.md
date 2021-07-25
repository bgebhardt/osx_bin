# Karabiner README

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) is a powerful and stable keyboard customizer for macOS.

I use it to add Emacs-like keybindings as well as to map left control to capslock. My keybindings are in this karabiner.json are inspired by this post [Use emacs key bindings everywhere - Atif Afzal](https://atfzl.com/use-emacs-key-bindings-everywhere).

Some other examples of karabiner configurations
* [GitHub - drliangjin/karabiner.d: A simple keyboard configuration using Karabiner-Elements](https://github.com/drliangjin/karabiner.d)
* [GitHub - tekezo/Karabiner: Karabiner (KeyRemap4MacBook) is a powerful utility for keyboard customization.](https://github.com/tekezo/Karabiner)

The Cocoa text system has many of these bindings built in as noted in this post: [Emacs Keybindings for Mac OS X | Irreal](https://irreal.org/blog/?p=259).  But they do not work in every application so using Karbiner will make it

On Windows [AutoHotkey](https://www.autohotkey.com/) is a similar tool that can accomplish this too.

* [Documentation | Karabiner-Elements](https://karabiner-elements.pqrs.org/docs/)

# Keybindings Summary

The keybindings I have implemented are:

* "Ctrl+F to right_arrow, Ctrl+B to left arrow",
* "Ctrl+P to up_arrow, Ctrl+N to down_arrow",
* "Ctrl+G to Escape",
* "Ctrl+A and Ctrl+E to beginning/end of line",
* "Ctrl+V and Option-V to page down and page up"

Others to consider:

* Ctrl+D to forward delete
* Ctrl+K to kill line which can be broken down into:
    * home, shift down, end, shift up to select line
    * command-x to cut
    * delete to delete selection (although may not be needed)
* Ctrl+Y to paste (i.e. "yank" or "command-v")
* Option-F, Option-B - Forward and Backward a word using option-right and option-left arrow
* Forward Kill Word using two keys: option+shift+right arrow; command+x to cut

# Apps to exclude

Unfortunately in each keybinding you have to add a connection to exclude apps which results in a lot of repetition.

These apps I've added exclusion rules for.  I'm sure I'll find more

* "^org\\.gnu\\.Emacs$",
* "^com\\.apple\\.TextEdit$"

# Example Keybinding

Here's an example complex modification for an Emacs keybinding.

```
{
                        "description": "Ctrl+E to end of line",
                        "manipulators": [
                          {
                            "description": "emacs like movement",
                            "from": {
                              "key_code": "e",
                              "modifiers": {
                                "mandatory": [
                                  "left_control"
                                ]
                              }
                            },
                            "to": [
                              {
                                "key_code": "end"
                              }
                            ],
                            "conditions": [
                              {
                                "type": "frontmost_application_unless",
                                "bundle_identifiers": [
                                  "^org\\.gnu\\.Emacs"
                                ]
                              }
                            ],
                            "type": "basic"
                          }
                        ]
                      }
```

