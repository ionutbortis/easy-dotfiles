[quick demo doc url]: ./quick-demo.md#quick-demo

# `easy-dotfiles` :palm_tree: docs :book:

This guide will help you master everything you need to know about **`easy-dotfiles`**'s awesomeness :star_struck:

If this is your first time here, please **check out first** the [Quick demo][quick demo doc url] section and come back here after you successfully configured the demo sample on a Virtual Machine.

### Contents:

<!-- start TOC -->

- [DISCLAIMER](./disclaimer.md#disclaimer)
- [Quick demo](./quick-demo.md#quick-demo)
  - [Experience some magic](./quick-demo.md#experience-some-magic)
  - [How to use other git providers?](./quick-demo.md#how-to-use-other-git-providers)
    - [Clone the github repository](./quick-demo.md#clone-the-github-repository)
- [Main desktop setup](./main-desktop-setup.md#main-desktop-setup)
  - [Git setup](./main-desktop-setup.md#git-setup)
    - [Adding new profiles](./main-desktop-setup.md#adding-new-profiles)
    - [Update your `easy-dotfiles` repo](./main-desktop-setup.md#update-your-easy-dotfiles-repo)
      - [Github](./main-desktop-setup.md#github)
      - [Other git providers](./main-desktop-setup.md#other-git-providers)
- [JSON configuration](./json-configuration.md#json-configuration)
  - [Applications](./json-configuration.md#applications)
    - [What if...](./json-configuration.md#what-if)
      - [An app comes preinstalled on some distros?](./json-configuration.md#an-app-comes-preinstalled-on-some-distros)
      - [My app is a flatpak and has the same install command?](./json-configuration.md#my-app-is-a-flatpak-and-has-the-same-install-command)
      - [I have an app that has a weird install command?](./json-configuration.md#i-have-an-app-that-has-a-weird-install-command)
      - [My app is not found in the default package repositories?](./json-configuration.md#my-app-is-not-found-in-the-default-package-repositories)
      - [I have config files and also `dconf` entries for an app?](./json-configuration.md#i-have-config-files-and-also-dconf-entries-for-an-app)
  - [Extensions](./json-configuration.md#extensions)
  - [Keybindings](./json-configuration.md#keybindings)
  - [Miscellaneous](./json-configuration.md#miscellaneous)
  - [Tweaks](./json-configuration.md#tweaks)
    - [How to filter for specific `dconf` keys or sub-path](./json-configuration.md#how-to-filter-for-specific-dconf-keys-or-sub-path)
- [Shell scripts](./shell-scripts.md#shell-scripts)
  - [`defaults.sh` script](./shell-scripts.md#defaultssh-script)
    - [Add a new supported distro](./shell-scripts.md#add-a-new-supported-distro)
  - [`setup.sh` scripts](./shell-scripts.md#setupsh-scripts)
    - [Public `common/setup.sh` script](./shell-scripts.md#public-commonsetupsh-script)
    - [Private `common/setup.sh` script](./shell-scripts.md#private-commonsetupsh-script)
    - [Private _distro specific_ `setup.sh` script](./shell-scripts.md#private-distro-specific-setupsh-script)
  - [`easy-dotfiles` main scripts](./shell-scripts.md#easy-dotfiles-main-scripts)
    - [`git` scripts](./shell-scripts.md#git-scripts)
    - [`export.sh`](./shell-scripts.md#exportsh)
    - [`import.sh`](./shell-scripts.md#importsh)
    - [`install.sh`](./shell-scripts.md#installsh)
    - [`remove.sh`](./shell-scripts.md#removesh)
    - [`anacron` setup](./shell-scripts.md#anacron-setup)
- [Scheduling automatic actions](./automatic-actions.md#scheduling-automatic-actions)
  - [Git SSH keys](./automatic-actions.md#git-ssh-keys)
  - [Export](./automatic-actions.md#export)
  - [Import](./automatic-actions.md#import)
  - [Remove or reschedule](./automatic-actions.md#remove-or-reschedule)
- [Tips \& Tricks](./tips-and-tricks.md#tips--tricks)
  - [Unattended `install` run (mostly)](./tips-and-tricks.md#unattended-install-run-mostly)
  - [Testing scheduled action](./tips-and-tricks.md#testing-scheduled-action)
  - [Partial import](./tips-and-tricks.md#partial-import)
  - [Passworldless SSH keys](./tips-and-tricks.md#passworldless-ssh-keys)
  - [Hacking away](./tips-and-tricks.md#hacking-away)

<!-- end TOC -->
