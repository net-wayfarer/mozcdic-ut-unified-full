# Mozc UT Dictionary for distribute in AUR

## Upstream

- [utuhiro's mozcdic-ut](http://linuxplayers.g1.xrea.com/mozc-ut.html)
- [file list](https://osdn.net/users/utuhiro/pf/utuhiro/files/)

## AUR

[mozc-ut-unified](https://aur.archlinux.org/packages/mozc-ut-unified/)

## How to install

Use trizen.

```bash
trizen -S mozc-ut-unified
```

yay.

```bash
yay -S mozc-ut-unified
```

pamac.

```bash
pamac install mozc-ut-unified
```

or manually

```
git clone https://aur.archlinux.org/mozc-ut-unified.git
cd mozc-ut-unified
makepkg
sudo pacman -U *.pkg.tar.xz
```
