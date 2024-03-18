# Fedora Generic &nbsp; [![build-ublue](https://github.com/lorduskordus/fedora-generic/actions/workflows/build.yml/badge.svg)](https://github.com/lorduskordus/fedora-generic/actions/workflows/build.yml)

Custom Linux OS images built with ease using the [BlueBuild](https://blue-build.org/) project. BlueBuild is a collection of tools and documentation that allows to easily build custom images, without having to know about stuff like containerfiles, that are common to image building. You can [make your own](https://blue-build.org/how-to/setup/) !

The images are based on the [Universal Blue (uBlue)](https://universal-blue.org/) project, a.k.a. [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) on steroids. Universal Blue takes Fedora Atomic OCI images and adds QoL changes on top, that Fedora itself can't, like NVIDIA drivers or codecs.

These images have additional 'minimal' QoL changes applied on top and serve as a 'base' for building more personalised images, like:

* [Fedora LK](https://github.com/lorduskordus/fedora-lk) - containing images I daily drive

## Images

##### GNOME (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-generic-gnome-nvidia
```
##### KDE (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-generic-kde-nvidia
```