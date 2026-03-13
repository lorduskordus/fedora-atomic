<div align="center">
    <img src="assets/fedora-transparent.svg" width="150" title="Fedora logo">
    <h1>
        Fedora Atomic
        <br>
        <a href="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build-all.yml">
            <img src="https://github.com/lorduskordus/fedora-atomic/actions/workflows/build-all.yml/badge.svg" alt="build-all">
        </a>
    </h1>
    <h3>
        Customized <a href="https://fedoraproject.org/atomic-desktops">Fedora Atomic Desktop</a> built with <a href="https://blue-build.org">BlueBuild</a> on top of <a href="https://universal-blue.org">Universal Blue</a>
    </h3>
    <br>
</div>

## Installation

To rebase an existing [Fedora Atomic Desktop](https://fedoraproject.org/atomic-desktops) installation to the latest build:

- ##### First rebase to the unsigned image, to get the proper signing keys and policies installed
  ```sh
  bootc switch ghcr.io/lorduskordus/<IMAGE>
  ```
- ##### Reboot to complete the rebase
  ```sh
  systemctl reboot
  ```
- ##### Then rebase to the signed image
  ```sh
  bootc switch --enforce-container-sigpolicy ghcr.io/lorduskordus/<IMAGE>
  ```
- ##### Reboot again to complete the installation
  ```sh
  systemctl reboot
  ```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo (under the images folder) and running the following command:

```sh
cosign verify --key cosign.pub ghcr.io/lorduskordus/<IMAGE>
```
