# Fedora Base &nbsp; [![build-ublue](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml/badge.svg)](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml)

> The [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops/) is a non-traditional Linux distribution, which provides additional stability and reliability by making parts of the system immutable. That means the base system always stays clean and in a working state. Updates are atomic and applied on reboot. When the system is updated and booted into, the previous state is kept. Should any problems occur, it is possible to rollback to that state.

> The [Universal Blue (uBlue)](https://universal-blue.org/) project takes Fedora Atomic OCI images and adds QoL changes on top, like NVIDIA drivers, codecs, distrobox or services providing automatic updates.

> The [BlueBuild](https://blue-build.org/) project makes image building easy by allowing you to declare your modifications in yaml files using modules with an easy to understand syntax, serving as an abstraction to a classic containerfile. The images are built daily by default using a GitHub Action.

These images have additional QoL changes applied on top. They are supposed to be 'generic'.

All the images have Bazzite & CoreOS kernel variants available. To minimize build failures related to the custom kernels & the included NVIDIA drivers, images with kernels other than Main are built on top of [Fedora Core](https://github.com/lorduskordus/fedora-core), which serves as a 'cache' of successfully built images that are then used here.

All my experimenting, potentially breaking changes and heavy personalization is done on top of these images in:

* [Fedora LK](https://github.com/lorduskordus/fedora-lk)

## Images

##### COSMIC
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-cosmic
```
##### COSMIC (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-cosmic-nvidia
```
##### GNOME
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-gnome
```
##### GNOME (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-gnome-nvidia
```
##### KDE
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-kde
```
##### KDE (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-kde-nvidia
```
