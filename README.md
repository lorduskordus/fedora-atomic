<div align="center">
    <img src="assets/fedora-transparent.svg" width="150" title="Fedora logo">
</div>

<h1 align="center">
    Fedora Atomic
    <br>
    <a href="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build-all.yml">
        <img src="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build-all.yml/badge.svg" alt="build-all">
    </a>
</h1>

<h3 align="center">
    Customized <a href="https://fedoraproject.org/atomic-desktops">Fedora Atomic Desktop</a> built with <a href="https://blue-build.org">BlueBuild</a> on top of <a href="https://universal-blue.org">Universal Blue</a>
</h3>

<br>

## Images

### Base (kinda generic)

- ##### COSMIC
  ```
  ghcr.io/lorduskordus/fedora-base-cosmic
  ```
- ##### COSMIC (NVIDIA)
  ```
  ghcr.io/lorduskordus/fedora-base-cosmic-nvidia
  ```
- ##### KDE
  ```
  ghcr.io/lorduskordus/fedora-base-kde
  ```
- ##### KDE (NVIDIA)
  ```
  ghcr.io/lorduskordus/fedora-base-kde-nvidia
  ```

### Next (more opinionated, experimental)

- ##### COSMIC (NVIDIA)
  ```
  ghcr.io/lorduskordus/fedora-next-cosmic
  ```
- ##### KDE (NVIDIA)
  ```
  ghcr.io/lorduskordus/fedora-next-kde
  ```

## Installation

To rebase an existing [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops) installation to the latest build:

- ##### First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  bootc switch ghcr.io/lorduskordus/fedora-base-kde:latest
  ```
- ##### Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- ##### Then rebase to the signed image, like so:
  ```
  bootc switch --enforce-container-sigpolicy ghcr.io/lorduskordus/fedora-base-kde:latest
  ```
- ##### Reboot again to complete the installation
  ```
  systemctl reboot
  ```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo (under the images folder) and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/lorduskordus/fedora-base-kde:latest
```
