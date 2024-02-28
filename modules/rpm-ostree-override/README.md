# rpm-ostree-override Module

The `rpm-ostree-override` module allows replacing packages already included in the base image using `rpm-ostree override`.

The module first downloads the repository file from repository declared under `repo:` into `/etc/yum.repos.d/`. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version), which can be used, for example, for pulling correct versions of repositories from [Fedora's Copr](https://copr.fedorainfracloud.org/). There are corrections for wrong Fedora versions in place as well, but don't count on that.

The module then replaces the packages declared under `replace:` using `rpm-ostree override replace`.

Lastly, the repository file is removed from `/etc/yum.repos.d/`.

The module can only replace packages from one repository at a time. If you want to do multiple replacements from different repositories, use the module again separately for all your repositories.

## Example Configuration:

```yaml
type: rpm-ostree-override
repo:
    - https://copr.fedorainfracloud.org/coprs/trixieua/mutter-patched/repo/fedora-%OS_VERSION%/trixieua-mutter-patched.repo
replace:
    - mutter
    - mutter-common
    - xorg-x11-server-Xwayland
```