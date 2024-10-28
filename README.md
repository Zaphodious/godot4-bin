# NixOS Godot Binaries

> Official Godot binary packages for NixOS
(including godot-mono for C# support!)

## Getting Started

### Without Flakes ❄❌

Unsupported

### With Flakes ❄✅

#### Running Godot without installing it

To run Godot(Mono version) without any further configuration, run this command:

```bash
nix run github:Damianu/godot4-bin
```

##### Running different Godot flavors

There are also two other options available to run Godot:

```bash
nix run github:Damianu/godot4-bin#godot
nix run github:Damianu/godot4-bin#godot-mono
```

Most importantly, using `#godot-mono` will allow you to write in C#.

#### Installing Godot using flakes system-wide

Put this in your `flake.nix`, to install Godot for your user:

```nix
  inputs = {
    # ...
    godot-bin = {
      url = "github:Damianu/godot4-bin";
      inputs.nixpkgs.follows = "nixpkgs"; #Might prevent some OpenGL issues
    };
    # ...
  };

  outputs = { self, nixpkgs, ... }@attrs:
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ({ config, nixpkgs, ...}@inputs:
          users.users.YOURUSERNAME.packages = [
            # ...
            inputs.godot-bin.packages.x86_64-linux.godot # for godot without Mono / C#
            inputs.godot-bin.packages.x86_64-linux.godot-mono
          ]
        )
      ]
```

Alternatively you can also install Godot system-wide like this:

```nix
  inputs = {
    # ...
    godot-bin = {
      url = "github:Damianu/godot4-bin";
      inputs.nixpkgs.follows = "nixpkgs"; #Might prevent some OpenGL issues
    };
    # ...
  };

  outputs = { self, nixpkgs, ... }@attrs:
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ({ config, nixpkgs, ...}@inputs:
          environment.systemPackages = [
            # ...
            inputs.godot-bin.packages.x86_64-linux.godot # for godot without Mono / C#
            inputs.godot-bin.packages.x86_64-linux.godot-mono
          ]
        )
      ]
```

#### Overriding version

Version can be overriden via overrideAttrs via "version" and "versionHash" property

Example version: "4.3-stable"

# Why this fork

- Provides option to override version(and versionHash)
- nixpkgs currently doesnt provide godot4 with mono
- Quick tests show it actually works ;)
- Icon/Desktop/Man files pinned to actual commit link instead of master branch, so won't error when Godot repo gets updated.