# Mozc UT Dictionary for distribute in AUR

## Upstream

- [utuhiro's mozcdic-ut](http://linuxplayers.g1.xrea.com/mozc-ut.html)
- [file list](https://osdn.net/users/utuhiro/pf/utuhiro/files/)

## AUR

[mozc-ut-unified-full](https://aur.archlinux.org/packages/mozc-ut-unified-full/)

## How to install

Use trizen.

```bash
trizen -S mozc-ut-unified-full
```

yay.

```bash
yay -S mozc-ut-unified-full
```

pamac.

```bash
pamac install mozc-ut-unified-full
```

or manually

```
git clone https://aur.archlinux.org/mozc-ut-unified-full.git
cd mozc-ut-unified-full
makepkg
sudo pacman -U *.pkg.tar.xz
```

# Acknowledgements

`make-dictionaries.bash` was contributed by [tuxsavvy](https://aur.archlinux.org/packages/fcitx-mozc-ut-unified-full).