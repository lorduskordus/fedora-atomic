# Fedora Base &nbsp; [![build-ublue](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml/badge.svg)](https://github.com/lorduskordus/fedora-base/actions/workflows/build.yml)

Custom [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops/) images based on [Universal Blue (uBlue)](https://universal-blue.org/), built with ease using [BlueBuild](https://blue-build.org/).

The **BlueBuild** project makes image building easy by allowing you to declare your modifications in a yaml file using modules with an easy to understand syntax, serving as an abstraction to a classic containerfile. The images are built daily by default using a GitHub Action.

The **Universal Blue (uBlue)** project, a.k.a. Fedora Atomic on steroids, takes Fedora Atomic OCI images and adds QoL changes on top, that Fedora itself can't, like NVIDIA drivers or codecs.

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
