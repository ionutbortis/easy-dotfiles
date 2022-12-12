<!-- start header -->

[<< Back to contents][contents doc url]

---

<!-- end header -->

<!-- start TOC -->

- [Shell scripts](#shell-scripts)
  - [`defaults.sh` script](#defaultssh-script)
    - [Add a new supported distro](#add-a-new-supported-distro)
  - [`setup.sh` scripts](#setupsh-scripts)
    - [Public `common/setup.sh` script](#public-commonsetupsh-script)
    - [Private `common/setup.sh` script](#private-commonsetupsh-script)
    - [Private _distro specific_ `setup.sh` script](#private-distro-specific-setupsh-script)
  - [`easy-dotfiles` main scripts](#easy-dotfiles-main-scripts)
    - [`git` scripts](#git-scripts)
    - [`export.sh`](#exportsh)
    - [`import.sh`](#importsh)
    - [`install.sh`](#installsh)
    - [`remove.sh`](#removesh)
    - [`anacron` setup](#anacron-setup)

<!-- end TOC -->

# Shell scripts

So you had some fun times while reading the [JSON configuration][json configuration doc url] section and you want to know if there are any other places where you might change a thing or two.

Fortunately (or unfortunately?) there aren't so many other places you can fiddle with, except some shell scripts that are kept into your private repository.

## `defaults.sh` script

You might vaguely remember something about a [`defaults.sh`][defaults script] script from the _good ol' times_ when you did the [Quick demo][quick demo doc url] tutorial. During that tutorial, the git setup script should have asked you if you want to use the provided sample in order to initialize your private repository. Of course you said `yes` and now you should have a properly configured [`defaults.sh`][defaults script] script in your private repository.

If not, well, let me tell you what's the deal with this file.

The [`defaults.sh`][defaults script] contains some bash constants that will be used when configuring **`easy-dotfiles`**. It's a cool way of not needing to type your `computer name`, `git name` or `git email` each time you configure **`easy-dotfiles`** on another system:

```sh
DEFAULT_HOST_NAME="myPC"

DEFAULT_GIT_NAME="My Name"
DEFAULT_GIT_EMAIL="my.git.account.email@domain.com"
```

You can also manually edit this file if you're not happy with the default values you configured during the first git setup run:

```sh
nano ~/easy-dotfiles/private/scripts/defaults.sh
```

Beside the above constants, the `defaults.sh` script contains also a very vital configuration, the `SUPPORTED_DISTROS` list:

```sh
SUPPORTED_DISTROS=( "fedora" "ubuntu" )
```

When you run the **`easy-dotfiles`** install script, you're prompted to select the distro you want to run it for. The list is populated with the values from this `bash` array.

Out of the box, **`easy-dotfiles`** knows of `fedora` and `ubuntu` but you can extend / replace this with your own preferred distros.

If you're fine just with those you can skip directly to the [setup.sh scripts](#setupsh-scripts) section, otherwise, please carry on reading.

### Add a new supported distro

Adding a new supported distro is fairly simple, just a couple of small steps.

**First** you need to add a new element to the `SUPPORTED_DISTROS` array in your private `defaults.sh` file:

```sh
~/easy-dotfiles/private/scripts/defaults.sh`
```

**NOTE:** The `SUPPORTED_DISTROS` configuration should be left as a bash array and its elements should be strings containing **STRICTLY** only **letters**, **numbers** and the **underscore** `_` character. **No spaces, dashes or other characters** are allowed inside distro names except underscore!

If you need to use multiple words, you can use the camel case style or an underscore:

- camelCase: `popOS` `linuxMint` `openSUSE`
- underscore: `pop_OS` `linux_mint` `open_SUSE`

Let's say that you want to support `popOS` along `fedora` and `ubuntu`. The `SUPPORTED_DISTROS` configuration from the `defaults.sh` file should look like:

```sh
SUPPORTED_DISTROS=( "fedora" "ubuntu" "popOS" )
```

The **second step** is to go to your private app config json file and add `popOS` install commands for all the needed apps:

```sh
~/easy-dotfiles/private/config/apps/config.json
```

`popOS` is based on `ubuntu` so you can just add the `popOS` name next to the `ubuntu` name, in the same field, separated by space:

```json
{
  "name": "Extension Manager", 
  "url": "https://flathub.org/apps/details/com.mattjakeman.ExtensionManager", 
  "install": {
    "fedora ubuntu popOS": "sudo flatpak install flathub com.mattjakeman.ExtensionManager -y --noninteractive"
  }
}, 
{
  "name": "dconf Editor", 
  "url": "https://wiki.gnome.org/Apps/DconfEditor", 
  "install": {
    "fedora": "sudo dnf install dconf-editor -y", 
    "ubuntu popOS": "sudo apt-get install dconf-editor -y"
  }
}
```

If you want to support only `popOS` you would remove the `fedora` and `ubuntu` entries from these files:

- `~/easy-dotfiles/private/scripts/defaults.sh`
- `~/easy-dotfiles/private/config/apps/config.json`

**NOTE:** Just make sure that the `SUPPORTED_DISTROS` configuration is still a bash array:

```sh
SUPPORTED_DISTROS=( "popOS" )
```

For other distros that might use another package manager you need to add a separate install command:

```json
{
  "name": "dconf Editor", 
  "url": "https://wiki.gnome.org/Apps/DconfEditor", 
  "install": {
    "fedora": "sudo dnf install dconf-editor -y", 
    "ubuntu popOS": "sudo apt-get install dconf-editor -y", 
    "arch": "sudo pacman -Sy dconf-editor --noconfirm"
  }
}
```

The **third** and final step is to add a new `popOS` specific setup script to this path:

```sh
~/easy-dotfiles/private/scripts/popOS/setup.sh
```

The new `popOS/setup.sh` script has to be executable and (hopefully) run without errors. Here you can put whatever tinkering you need to do to your `popOS` machine before installing the **`easy-dotfiles`** managed apps and extensions.

These distro specific setup scripts are called by the **`easy-dotfiles`** install script depending on your selected option when asked. They are a nice way to deeply customize your distro to your needs. More on them in the next section.

## `setup.sh` scripts

There are several `setup.sh` scripts spread throughout the **`easy-dotfiles`** files. We will talk here mainly about the **private** scripts (`~/easy-dotfiles/private/scripts`) that I recommend you take a look at and change them according to your needs. They were coded using [bash](https://www.gnu.org/software/bash/) but I guess you could change the `#!/bin/bash` line to suit your preferred script coding language.

### Public `common/setup.sh` script

The **`easy-dotfiles`** `install` script will first run the _public_ [`common/setup.sh`][common setup script] script. This script will get your default computer name from your private `defaults.sh` script and will ask you to enter your desired computer name. You can use that default name by pressing `Enter` or provide a different name. You will be prompted for your terminal `sudo` password in order to set the new computer name. This way you won't be prompted again for terminal `sudo` password during the install process.

The _public_ [`common/setup.sh`][common setup script] script will also try to invoke the _private_ [`common/setup.sh`][sample common setup script] script.

**NOTE:** If the _private_ `common/setup.sh` script cannot be found or executed, a warning message will be displayed but the install execution will continue.

### Private `common/setup.sh` script

The _private_ [`common/setup.sh`][sample common setup script] script should be found on your installation at this path:

```sh
~/easy-dotfiles/private/scripts/common/setup.sh
```

The provided sample already contains [this script][sample common setup script] but it doesn't do anything, just prints out a message.

The _private_ `common/setup.sh` script is useful if **you have some common tasks** to be performed for **all of your supported distros**. Maybe you want to create some additional users or to clone some of your private git repositories. For example, I use it to setup a battery charge limit for my laptop.

**NOTE:** Because you might run the `install` script multiple times, please make sure that your `common/setup.sh` script **can also run multiple times in a row**, without problematic results like duplicated files, configuration, etc.

### Private _distro specific_ `setup.sh` script

Each supported distro can have their own specific `setup.sh` script. The _distro specific_ setup scripts are located on your private repository and there is a convention on what their path should be.

Out of the box, **`easy-dotfiles`** sample has specific `setup.sh` scripts for [`fedora`][fedora setup script] and [`ubuntu`][ubuntu setup script]. On your local installaion of **`easy-dotfiles`** they are located at:

- fedora: `~/easy-dotfiles/private/scripts/fedora/setup.sh`
- ubuntu: `~/easy-dotfiles/private/scripts/ubuntu/setup.sh`

You can observe that the pattern for the _distro specific_ `setup.sh` script path is:

```sh
~/easy-dotfiles/private/scripts/DISTRO/setup.sh
```

The name of the `DISTRO` folder should be **EXACTLY** the distro name configured into the `SUPPORTED_DISTROS` array from your private `defaults.sh` script.

When you run the **`easy-dotfiles`** install script you are prompted to select the distro for setup and depending on your choice, the corresponding _distro specific_ `setup.sh` script is invoked.

The _distro specific_ `setup.sh` scripts are a very good place to put in the things you usually change after the distro installation.

If you are on [`fedora`][fedora setup script] you might want to make `dnf` run faster, add flathub, enable rpm fusion, add missing software repos and so on.

If you are on [`ubuntu`][ubuntu setup script] you might want to add flatpak support, replace the preinstalled snap Firefox with the faster deb version, add missing software repos and so on.

By configuring the missing app repos during the _distro specific_ `setup.sh` script run, you can have simple `apt-get install` or `dnf install` commands into the [apps config][apps config json] json file.

**NOTE:** Because you might run the `install` script multiple times, please make sure that your _distro specific_ `setup.sh` scripts **can also run multiple times in a row**, without problematic results like duplicated files, configuration, etc.

This is all about the shell scripts that you can customize to your needs.

Please continue on reading the next section to learn more about **`easy-dotfiles`** **main scripts** that will help you easily manage your files and settings.

## `easy-dotfiles` main scripts

As you could probably tell by now, **`easy-dotfiles`** is a collections of [shell scripts](https://en.wikipedia.org/wiki/Shell_script) written in [bash](<https://en.wikipedia.org/wiki/Bash*(Unix_shell)>).

_Why Bash?_ Why not? It is usually the default shell on many linux distros, maybe with some masochistic syntax constructs from time to time but overall not a horrible developer experience.

If you're using `bash 5.0.17` or above you shouldn't have any problems in running the scripts.

The **`easy-dotfiles`** [main shell scripts][main scripts] are located in the `scripts` folder under the project's root:

```sh
cd ~/easy-dotfiles/ && tree scripts/
```

### `git` scripts

The first thing you should **ALWAYS** do after cloning locally your **`easy-dotfiles`** git repo (`cd ~ && git clone --recurse-submodules your_easy-dotfiles_repo_SSH_URL`) is running the [git setup script][git setup script]:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

This will ensure that your local installation of **`easy-dotfiles`** is properly configured and you can use safely the other scripts.

There are also some other `git` related scripts that should help in smoothing your experience with the **`easy-dotfiles`** `git` repos:

- [`push.sh`][git push script] script
  - Pushes your local changes to the remote **`easy-dotfiles`** `git` repositories (main and private).
  - It adds a `git commit` message so you don't have to type one.
  - Useful when you did some configuration changes, exported your data and now you want to push it to the clouds.

```sh
cd ~/easy-dotfiles/ && ./scripts/git/push.sh
```

- [`pull.sh`][git pull script] script
  - Pulls locally the new changes from the remote **`easy-dotfiles`** `git` repositories (main and private).
  - Useful when you did some configuration changes on a different machine, exported and pushed your data to the clouds and now you want to get that data also on this machine.

```sh
cd ~/easy-dotfiles/ && ./scripts/git/pull.sh
```

- [`reset.sh`][git reset script] script
  - Resets your local installation of **`easy-dotfiles`** to the state of the remote `git` repositories.
  - Useful if you want to revert your local changes from **`easy-dotfiles`**. Maybe you get some `git` errors and you cannot push your changes. **Just make sure** that you **copy your local changes** in some other place because this script will revert them.

```sh
cd ~/easy-dotfiles/ && ./scripts/git/reset.sh
```

There's no issue if you prefer using native `git` commands, [Github Desktop](https://github.com/shiftkey/desktop), [Visual Studio Code](https://code.visualstudio.com/) or other [IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment) for handling your work with the git repositories. Most of the time I find myself using _Visual Studio Code_ for all the **`easy-dotfiles`** configuration changes and git related stuff.

### `export.sh`

The [export script][export script] does the heavy lifting of exporting files and settings **from** _your system_ **to** _your local installation_ of **`easy-dotfiles`**:

```sh
cd ~/easy-dotfiles/ && ./scripts/export.sh
```

**`easy-dotfiles`** **doesn't create symlinks**, it copies your [configured files and settings][json configuration doc url] to your local private git repository.

I believe I started using `stow` for creating symlinks but at one time I just dropped the idea in order to keep it as simple as possible. Even though storage capacity has increased significantly in the latest years, I **don't recommend** using **`easy-dotfiles`** for managing your **media library**. It should be used **mainly** for **dotfiles**, **dconf settings** and maybe some other **small miscellaneous files**.

**NOTE:** After the `export.sh` script run, you'll have to push your local changes to the remote `git` repositories.

- Check out the [git scripts](#git-scripts) section to see how you can manually do that.
- Check out the [Automatic actions][automatic actions doc url] section if you want the export and push to be done automatically on a scheduled basis.

### `import.sh`

The [import script][import script] gets the [configured files and settings][json configuration doc url] from your local **`easy-dotfiles`** private repository and imports them to **your system**. Importing implies **overriding of files and settings on your system**.

**NOTE:** **YOU SHOULD ALWAYS** backup your files before running scripts that override files on your system!

 Please go and read the [DISCLAIMER][disclaimer doc url] section if you haven't done that already.

The intended purpose of the `import.sh` script is to help in restoring a previously exported **`easy-dotfiles`** data. Usually you would do this manually after installing a fresh linux desktop:

```sh
cd ~/easy-dotfiles/ && ./scripts/import.sh
```

The basic workflow would be:

- Configure **`easy-dotfiles`** on your main linux desktop, export data and push it to the private git repository.
- Install a fresh linux desktop OS on the same machine, another machine or a Virual Machine, configure **`easy-dotfiles`** over there, run the `install.sh` and `import.sh` scripts. You now have all the apps, extensions, installed and configured with your settings.

Some people might want to mirror their `main desktop` setup to another machine or VM. Then you would want to periodically pull the latest changes from your private repo and run the `import.sh` script. This assumes that the `main desktop` has **`easy-dotfiles`** configured and the `export.sh` script run and data push to private repo are performed periodically.

Check out the [Automatic actions][automatic actions doc url] section if you want the private repo data pull and import to be done automatically on a scheduled basis.

### `install.sh`

The [install script][install script] will:

- First run the [public](#public-commonsetupsh-script) and [private](#private-commonsetupsh-script) common setup scripts, 
- Then the private [distro specific](#private-distro-specific-setupsh-script) setup script, 
- And afterwards it will install all of your configured [applications and extensions][json configuration doc url].

```sh
cd ~/easy-dotfiles/ && ./scripts/install.sh
```

**NOTE:** The `install.sh` script won't run the `import.sh` script. You **need to manually run** the `import.sh` script after a successful `install.sh` run.

### `remove.sh`

The [remove script][remove script] deletes your local **`easy-dotfiles`** installation and removes the `anacron` script if you had previously configured scheduled [automatic actions][automatic actions doc url]. It won't delete any of your remote git repositories.

**NOTE:** The `remove.sh` script **won't restore** the state of your files and settings before being overwritten by running the `import.sh` script. There isn't any backup feature builtin so you need to use an external solution if you desire that.

### `anacron` setup

[Anacron](https://en.wikipedia.org/wiki/Anacron) is a tool that can perform periodic actions on a `daily`, `weekly` or `monthly` basis on systems that don't run 24 hours a day. This tool is very suitable for our use case since we are dealing with a linux desktop that might be `ON` only for specific periods of time during the day.

The [anacron setup script][anacron setup script] is used for scheduling automatic actions:

```sh
cd ~/easy-dotfiles/ && ./scripts/anacron/setup.sh
```

If you want to learn more on how you can **schedule automatic actions** with **`easy-dotfiles`**, make sure you check out this [section][automatic actions doc url].

<!-- start footer -->

---

[<< Back to contents][contents doc url]

<!-- end footer -->

<!-- start links -->

[sample folder]:../../sample
[sample config folder]:../../sample/config
[sample data folder]:../../sample/data
[sample scripts folder]:../../sample/scripts
[sample common setup script]:../../sample/scripts/common/setup.sh
[apps config json]:../../sample/config/apps/config.json
[apps data folder]:../../sample/data/apps
[extensions config json]:../../sample/config/extensions/config.json
[extensions data folder]:../../sample/data/extensions
[keybindings config json]:../../sample/config/keybindings/config.json
[keybindings data folder]:../../sample/data/keybindings
[misc config json]:../../sample/config/misc/config.json
[misc data folder]:../../sample/data/misc
[tweaks config json]:../../sample/config/tweaks/config.json
[tweaks data folder]:../../sample/data/tweaks

<!-- -->

[main scripts]:../../scripts
[install script]:../../scripts/install.sh
[export script]:../../scripts/export.sh
[import script]:../../scripts/import.sh
[remove script]:../../scripts/remove.sh
[git setup script]:../../scripts/git/setup.sh
[git push script]:../../scripts/git/push.sh
[git pull script]:../../scripts/git/pull.sh
[git reset script]:../../scripts/git/reset.sh
[anacron setup script]:../../scripts/anacron/setup.sh
[common setup script]:../../scripts/common/setup.sh
[defaults script]:../../sample/scripts/defaults.sh
[jidea install script]:../../sample/scripts/apps/jidea-install.sh
[fedora setup script]:../../sample/scripts/fedora/setup.sh
[ubuntu setup script]:../../sample/scripts/ubuntu/setup.sh

<!-- -->

[contents doc url]:./README.md
[disclaimer doc url]:./disclaimer.md#disclaimer
[quick demo doc url]:./quick-demo.md#quick-demo
[main desktop setup doc url]:./main-desktop-setup.md#main-desktop-setup
[json configuration doc url]:./json-configuration.md#json-configuration
[shell scripts doc url]:./shell-scripts.md#shell-scripts
[common setup script doc url]:./shell-scripts.md#public-commonsetupsh-script
[private common setup script doc url]:./shell-scripts.md#private-commonsetupsh-script
[distro specific setup script doc url]:./shell-scripts.md#private-distro-specific-setupsh-script
[export script doc url]:./shell-scripts.md#exportsh
[import script doc url]:./shell-scripts.md#importsh
[install script doc url]:./shell-scripts.md#installsh
[git scripts doc url]:./shell-scripts.md#git-scripts
[distro setup scripts doc url]:./shell-scripts.md#private-distro-specific-setupsh-script
[anacron setup script doc url]:./shell-scripts.md#anacron-setup
[automatic actions doc url]:./automatic-actions.md#scheduling-automatic-actions
[tips and tricks doc url]:./tips-and-tricks.md#tips--tricks

<!-- end links -->
