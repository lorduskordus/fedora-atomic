# justfiles Module

The `justfiles` module allows for easy just files importing.

## What it does

1. It checks if the `config/justfiles` folder is present.
    
    * If it's not there, the module fails.

2. It finds all `.just` files inside of the `config/justfiles` folder or starting from the specified `include`.
    * If no `.just` files are found, the module fails.

    * The structure inside of that folder doesn't matter, you can place folders/files in there however you want, the module will find your `.just` files.

3. It copies over your files/folders to `/usr/share/bluebuild/justfiles`.

4. It generates import lines and appends them to the `/usr/share/ublue-os/just/60-custom.just` file.
    
    * If the generated import lines are already in there, the module fails to avoid duplications. 

## How to use it

Place all your `.just` files or folders with `.just` files inside the `config/justfiles` folder. If that folder doesn't exist, create it.

Without specifying `include`, it will assume you want to import everything. Otherwise, specify your files/folders under `include`.

### Example Configuration

```yaml
type: justfiles
include:
    - gnome_folder/monitors.just
    - justfiles_folder
```