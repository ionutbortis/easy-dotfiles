# `easy-dotfiles` :palm_tree:

Oh nooo, another dotfiles manager... :roll_eyes:

Oh YES! :sweat_smile: And let me tell you why **`easy-dotfiles`** is different and how by using it you can **fully set up** a new linux desktop in **minutes** :exploding_head: :rocket:

**`easy-dotfiles`** is a free and open source command line power tool, **most suited for** [Gnome](https://www.gnome.org/) **users**, that can help you manage your dotfiles, **automatically** install all your **favorite apps**, **extensions** and restore **your configuration** for them.

Let's say that you have a pretty sweet linux desktop setup :penguin: _Fedora_ or _Ubuntu_ or _whatever_, exactly the way you like it :heart_eyes: With a dock, or with a dash, with favorite apps, backgrounds, shortcuts, lots of tweaks to the Gnome shell, by using extensions or by dconf changes.

You spent some time in configuring it and you would like to replicate this setup on a different machine. Or on the same machine, but a different distro, or a fresh install. Or on a Virtual Machine, maybe testing the latest distro release, to check if all your apps and settings are working properly if you upgrade.

Well, **`easy-dotfiles`** :superhero: to the rescue then:

```sh
cd ~ && git clone --recurse-submodules git@your_git_provider:your_username/easy-dotfiles.git

cd ~/easy-dotfiles/scripts/ && ./git/setup.sh
./install.sh
./import.sh
```

That's all. Easy! :star_struck:

You have now a fully configured desktop, with all your favorite apps and Gnome extensions already installed and configured :tada:

Do you want to know how you can also do this? If yes, please carry on reading the [Quick demo](./docs/quick-demo.md#quick-demo) section to experience some magic :magic_wand:

**NOTE:** If you don't like emojis or you want to read the docs outside of `github.com`, there is also an [emoji free version](./docs/no-emoji/) of the markdown files. For the _emoji free_ version you should start with this [Quick demo](./docs/no-emoji/quick-demo.md#quick-demo) section.

---

Copyright (C) 2022 - 2022 Ionut Florin Bortis (ionutbortis@gmail.com)

This program is **free** for **personal** and **commercial** use and comes with **absolutely no warranty**. You use this program entirely at your own risk. The authors will not be liable for any damages arising from the use of this program.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Check out the included [LICENSE](./LICENSE) file or read more on the official [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html) website.
