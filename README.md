# Unofficial Hyprland Flake

> **WORK IN PROGRESS**

This flake was `filter-repo`'d out from [spikespaz/dotfiles].

We have yet to determine a permanent home for this code.
See [this issue comment](https://github.com/spikespaz/hyprland-flake/issues/1)
for an explanation.

## Usage

Add the flake as an input to your own.
The original flake from [hyprwm/hyprland] is included
as `hyprland-package` for the sole sake of keeping the packages used in
*this* flake up-to-date with Hyprland's default branch.

```nix
{
    inputs = {
        # The name `hyprland` is used for *this* flake.
        hyprland.url = "github:spikespaz/hyprland-flake";
        hyprland.inputs.hyprland.follows = "hyprland-package";
        # Track a different branch by appending `/branch-name` to the URL.
        # When it is omitted, the input will track the repository's
        # default branch.
        hyprland-package.url = "github:hyprwm/hyprland";
        # ...
    };
    # ...
}
```

Assuming that you know Nix well enough to have your flake's `inputs` passed
around to your Home Manager configuration, you can use the module in `imports`
somewhere.

```nix
{ lib, pkgs, inputs, ... }: {
    imports = [ inputs.hyprland.homeManagerModules.default ];

    wayland.windowManager.hyprland = {
        enable = true;
        reloadConfig = true;
        systemdIntegration = true;

        config = {
            # ...
        };
        # ...
    };
    # ...
}
```

## Updating

If you have adhered to the example in [Usage](#usage) for adding the two
necessary flake inputs, you can use the following command to update Hyprland
to the latest revision of the branch you have selected for `hyprland-package`.

```sh
nix flake lock --update-input hyprland-package
```

You can also update this flake separately. If you changed the name, remember to
adjust the following command accordingly.

```sh
nix flake lock --update-input hyprland
```

## Documentation

Because there is no documentation for module options yet, it is recommended to
browse through @spikespaz's configuration.

<https://github.com/spikespaz/dotfiles/tree/master/users/jacob/desktops/hyprland>

Remember that this example is a personal configuration,
which is under constant revision, so it may be a mess at times.

<!-- LINKS -->

[hyprwm/hyprland]: https://github.com/hyprwm/hyprland
[spikespaz/dotfiles]: https://github.com/spikespaz/dotfiles
