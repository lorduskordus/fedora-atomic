<div align="center">
    <img src="assets/fedora-transparent.svg" width="150" title="Fedora logo">
</div>

<h1 align="center">
    Fedora Atomic
    <br>
    <a href="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build.yml">
        <img src="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build.yml/badge.svg" alt="build-images">
    </a>
</h1>

<h3 align="center">
    Customized <a href="https://fedoraproject.org/atomic-desktops">Fedora Atomic Desktop</a> built with <a href="https://blue-build.org">BlueBuild</a> on top of <a href="https://universal-blue.org">Universal Blue</a>
</h3>

<br>

## Base Images (kinda generic)

##### COSMIC
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-cosmic
```
##### KDE
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-base-kde
```

<br>

## Next Images (more opinionated, experimental)

##### COSMIC (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-next-cosmic
```
##### KDE (NVIDIA)
```
ostree-image-signed:docker://ghcr.io/lorduskordus/fedora-next-kde
```
