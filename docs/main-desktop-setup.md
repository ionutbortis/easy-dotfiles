<!-- start header -->

[<< Back to contents][contents doc url]

---

<!-- end header -->

<!-- start TOC -->

- [Main desktop setup](#main-desktop-setup)
  - [Git setup](#git-setup)
    - [Adding new profiles](#adding-new-profiles)
    - [SSH keys](#ssh-keys)
    - [Update your `easy-dotfiles` repo](#update-your-easy-dotfiles-repo)
      - [Github](#github)
      - [Other git providers](#other-git-providers)

<!-- end TOC -->

# Main desktop setup

So you finished the [Quick demo][quick demo doc url] section and successfully configured the demo sample on a Virtual Machine. And now you want to know how to setup **`easy-dotfiles`** for your main desktop.

:exclamation:**NOTE:** If you didn't already, please go first to this [DISCLAIMER][disclaimer doc url] section and read it before continuing with the main desktop setup.

## Git setup

Since you already configured the demo sample, most of the git setup work is already done because you should already have the required git repositories:

- `easy-dotfiles` - This is the project's **public** repository. It holds all the scripts, docs and other public resources that are visible to everyone. This is the _brain_ of the project and it's generic by nature.

- `easy-dotfiles-private` - This is the project's **private** repository. It holds all of your configuration, dotfiles, settings and custom scripts. It should be private because of privacy reasons and the content is specific to your installation.

You need to get SSH URL for your `easy-dotfiles` repo and on your main desktop, run this in a terminal:

```sh
cd ~ && git clone --recurse-submodules your_easy-dotfiles_repo_SSH_URL
```

**I recommend** installing **`easy-dotfiles`** into your **`HOME`** folder's root. You can choose another path if you like, but you'll need to adapt the upcoming terminal commands because they will assume you installed the project on that path.

:exclamation:**NOTE:** The **FIRST** thing you should **ALWAYS** do after cloning locally the **`easy-dotfiles`** project is to run the git setup script:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

This is needed in order to properly configure you local installation of **`easy-dotfiles`**. If you intend to use **`easy-dotfiles`** only for one PC, you don't need to create separate profiles. The default `main` profile should be enough for you.

A `profile` is actually a [git branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches) created on the `easy-dotfiles-private` repository. This is helpful if you want to use **`easy-dotfiles`** with different configuration on multiple PCs or Virtual Machines.

**NOTE:** If this is your first time using **`easy-dotfiles`** I recommend that you **don't create yet any new profiles** and **first use** the `main` profile. This is helpful because all the new profiles are created having the `main` profile as a baseline. If you have a working `main` profile tailored to your needs, then it will be easier afterwards to tweak the new profiles because they will start as a copy of the `main` profile. You can skip the next git related sections and go directly to [JSON configuration][json configuration doc url].

### Adding new profiles

By using the git setup script `cd ~/easy-dotfiles/ && ./scripts/git/setup.sh` you can add a new profile or switch to an existing profile. This is useful when you already have a working `main` profile and you want to use **`easy-dotfiles`** for other PCs or Virtual Machines.

When creating a new profile you'll be prompted to enter its name and your local installation of **`easy-dotfiles`** will use that profile. This means that all of your private data will be pushed on a new branch created on the `easy-dotfiles-private` repository.

The name of the new profile must conform to the [git reference naming](https://git-scm.com/docs/git-check-ref-format) conventions which states that you can't have a branch name containing: `space` ` \ ~ ^ ? * : [` `@{` end with `.` or be single `@` char. The git setup script checks the name you provided according to the git rules and shows an error if it's not valid.

Some folks like to name their git branches using forward slashes `/`, simulating a folder structure. So you might name your **`easy-dotfiles`** profiles something like:

- `main`
- `home/pc`
- `home/laptop/lenovo`
- `home/laptop/fedora`
- `work/laptop`
- `vms/ubuntu/22.04`
- `vms/fedora/latest`

Or you can just use underscores `_` and/or dashes `-`. You have the power of naming profiles in a way that fits your needs :muscle:

If you don't want all your new profiles to be based on `main`, you need to manually change the `easy-dotfiles-private` repo's [default branch](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/changing-the-default-branch) in your git provider's interface or by terminal.

### SSH keys

TODO, needs investigation on the ssh keys passphrases

### Update your `easy-dotfiles` repo

There will be moments when you'll want to update your `easy-dotfiles` repository with the latest changes from my [github repository](https://github.com/ionutbortis/easy-dotfiles). Maybe some fixes or new features will be available there and you might want to have those also applied to your repo.

If you are using other git providers continue from [here](#other-git-providers).

#### Github

If you are using github as your git provider, you can easily update your forked `easy-dotfiles` repository from the website using this [guide](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork). Don't worry if you need to discard your commits on the `easy-dotfiles` repository because all you configuration, dotfiles and settings are stored on the `easy-dotfiles-private` repository.

After updating your forked `easy-dotfiles` repo on github you need to go on your local **`easy-dotfiles`** installations and perform a git pull. There is a script available for that and can be used like this:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/pull.sh
```

This should get locally all the new changes on your forked `easy-dotfiles` repo. If you get any errors and you don't know how to fix them, you can always reset your local installation by doing:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/reset.sh
```

If the git reset script didn't fix your issues you can go the last resort way, remove and reinstall the project:

```sh
cd ~ && rm -rf easy-dotfiles

cd ~ && git clone --recurse-submodules your_easy-dotfiles_repo_SSH_URL
```

:exclamation:**NOTE:** After updating your local **`easy-dotfiles`** installation, you **ALWAYS** need to run the git setup script to ensure that the installation is properly configured:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

During the local update you might lose the configured profile information so the git setup script run `cd ~/easy-dotfiles/ && ./scripts/git/setup.sh` is **MANDATORY**.

Don't worry, you won't actually lose your profiles if you update :sweat_smile:, the git branches will still exist on your `easy-dotfiles-private` repository, but your local installation might not know anymore where to put it's private data.

#### Other git providers

If you are using another git provider I will provide you a manual way to update your `easy-dotfiles` repo with the latest changes from my github repo. Don't worry, it's easy :smile_cat:

:exclamation:**NOTE:** I'm assuming that you already did the [Quick demo][quick demo doc url] setup and you already have the `easy-dotfiles` and `easy-dotfiles-private` repositories properly configured on your git provider.

:exclamation:**NOTE:** I'm also assuming that you already followed the [Git setup](#git-setup) section and you have a properly configured local installation of **`easy-dotfiles`** on your machine.

You need to clone my `easy-dotfiles` github repository on your local machine and rsync the new changes to your local installation of `easy-dotfiles`:

```sh
cd ~ && git clone https://github.com/ionutbortis/easy-dotfiles.git main-easy-dotfiles

rsync -a --delete \
    --exclude='.git/' --exclude='.gitmodules' --exclude='private/' \
    ~/main-easy-dotfiles/ ~/easy-dotfiles/

rm -rf ~/main-easy-dotfiles
```

Now you need to push the new changes to **your** remote `easy-dotfiles` repository:

```sh
cd ~/easy-dotfiles/ && git status

git add . && git commit . -m "Pulled changes from main <easy-dotfiles> github repo"
git push
```

You need to run the git setup script, just to be sure that everything is still properly configured on your local installation. Make sure that the proper profile is used and you can push your git configuration when asked:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

If you have multiple **`easy-dotfiles`** installations on different PCs or VMs, you need to log in to each of them and update your local installation with the changes you just pushed to your `easy-dotfiles` repository:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/pull.sh
```

After an update, you **ALWAYS** need to run the git setup script to ensure that the local installation is properly configured:

```sh
cd ~/easy-dotfiles/ && ./scripts/git/setup.sh
```

That's it! You successfully updated your main `easy-dotfiles` repository and all of your local **`easy-dotfiles`** installations :partying_face:

<!-- start footer -->

---

[<< Back to contents][contents doc url]

<!-- end footer -->

<!-- start links -->

[sample folder]: ../sample
[sample config folder]: ../sample/config
[sample data folder]: ../sample/data
[sample scripts folder]: ../sample/scripts
[sample common setup script]: ../sample/scripts/common/setup.sh
[apps config json]: ../sample/config/apps/config.json
[apps data folder]: ../sample/data/apps
[extensions config json]: ../sample/config/extensions/config.json
[extensions data folder]: ../sample/data/extensions
[keybindings config json]: ../sample/config/keybindings/config.json
[keybindings data folder]: ../sample/data/keybindings
[misc config json]: ../sample/config/misc/config.json
[misc data folder]: ../sample/data/misc
[tweaks config json]: ../sample/config/tweaks/config.json
[tweaks data folder]: ../sample/data/tweaks

<!-- -->

[main scripts]: ../scripts
[install script]: ../scripts/install.sh
[export script]: ../scripts/export.sh
[import script]: ../scripts/import.sh
[remove script]: ../scripts/remove.sh
[git setup script]: ../scripts/git/setup.sh
[git push script]: ../scripts/git/push.sh
[git pull script]: ../scripts/git/pull.sh
[git reset script]: ../scripts/git/reset.sh
[anacron setup script]: ../scripts/anacron/setup.sh
[common setup script]: ../scripts/common/setup.sh
[defaults script]: ../sample/scripts/defaults.sh
[jidea install script]: ../sample/scripts/apps/jidea-install.sh
[fedora setup script]: ../sample/scripts/fedora/setup.sh
[ubuntu setup script]: ../sample/scripts/ubuntu/setup.sh

<!-- -->

[contents doc url]: ./README.md
[disclaimer doc url]: ./disclaimer.md#disclaimer
[quick demo doc url]: ./quick-demo.md#quick-demo
[main desktop setup doc url]: ./main-desktop-setup.md#main-desktop-setup
[json configuration doc url]: ./json-configuration.md#json-configuration
[shell scripts doc url]: ./shell-scripts.md#shell-scripts
[common setup script doc url]: ./shell-scripts.md#public-commonsetupsh-script
[private common setup script doc url]: ./shell-scripts.md#private-commonsetupsh-script
[distro specific setup script doc url]: ./shell-scripts.md#private-distro-specific-setupsh-script
[export script doc url]: ./shell-scripts.md#exportsh
[import script doc url]: ./shell-scripts.md#importsh
[install script doc url]: ./shell-scripts.md#installsh
[git scripts doc url]: ./shell-scripts.md#git-scripts
[distro setup scripts doc url]: ./shell-scripts.md#private-distro-specific-setupsh-script
[anacron setup script doc url]: ./shell-scripts.md#anacron-setup
[automatic actions doc url]: ./automatic-actions.md#scheduling-automatic-actions
[tips and tricks doc url]: ./tips-and-tricks.md#tips--tricks

<!-- end links -->
