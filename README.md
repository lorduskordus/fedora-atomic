# Fedora Base &nbsp; [![build-ublue](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml/badge.svg)](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml)

> The [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops/) is a non-traditional Linux distribution, which provides additional stability and reliability by making parts of the system immutable. That means the base system always stays clean and in a working state. Updates are atomic and applied on reboot. By default, two previous states are kept when the system is updated. Should any problem occur, the previous state can be easily restored.

> The [Universal Blue (uBlue)](https://universal-blue.org/) project takes Fedora Atomic OCI images and adds QoL changes on top, like NVIDIA drivers, codecs, distrobox or services providing automatic updates.

> The [BlueBuild](https://blue-build.org/) project makes image building easy by allowing you to declare your modifications in yaml files using modules with an easy to understand syntax, serving as an abstraction to a classic containerfile. The images are built daily by default using a GitHub Action.

These images have additional 'minimal' QoL changes applied on top and serve as a 'base' for building more personalised images, like:

* [Fedora LK](https://github.com/lorduskordus/fedora-lk) - containing images I daily drive

## Images

#### GNOME
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-gnome
```
#### GNOME (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-gnome-nvidia
```
#### KDE
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-kde
```
#### KDE (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-kde-nvidia
```
