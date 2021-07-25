# Karabiner README

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) is a powerful and stable keyboard customizer for macOS.

I use it to add Emacs-like keybindings as well as to map left control to capslock. My keybindings are in this karabiner.json are inspired by this post [Use emacs key bindings everywhere - Atif Afzal](https://atfzl.com/use-emacs-key-bindings-everywhere).

The Cocoa text system has many of these bindings built in as noted in this post: [Emacs Keybindings for Mac OS X | Irreal](https://irreal.org/blog/?p=259).  But they do not work in every application so using Karbiner will make it

On Windows [AutoHotkey](https://www.autohotkey.com/) is a similar tool that can accomplish this too.

* [Documentation | Karabiner-Elements](https://karabiner-elements.pqrs.org/docs/)

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

