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

## Customization

#### Different .NET version

To customize the .NET version used by Godot, you can override the `dotnetPackage` attribute. By default, the package uses .NET 8 (Latest LTS).

```nix
  environment.systemPackages = [
    # ...
    (inputs.godot-bin.packages.x86_64-linux.godot-mono.override {
      dotnetPackage = pkgs.dotnet-sdk_6; # Specify your desired .NET version here
    })
  ];
```

Replace `inputs.nixpkgs.pkgs.dotnet-sdk_6` with the desired .NET package.

#### System .NET packages

To use the system-installed .NET packages instead, you can set the `setDotnetRoot` attribute to `false`. This will prevent setting DOTNET_ROOT by the wrapper.

```nix
  environment.systemPackages = [
    # ...
    (inputs.godot-bin.packages.x86_64-linux.godot-mono.override {
      setDotnetRoot = false;
    })
  ];
```

Ensure that the appropriate .NET version is installed on your system.

#### Overriding engine version

To override the engine version, you can use the `version` and `versionHash` properties. Here is an example:

```nix
  environment.systemPackages = [
    # ...
    (inputs.godot-bin.packages.x86_64-linux.godot-mono.override {
      version = "4.3-stable"; # Specify the desired Godot version here
      versionHash = "abcdef1234567890"; # Specify the corresponding version hash here
    })
  ];
```

Replace `"4.3-stable"` and `"abcdef1234567890"` with the desired version and its corresponding hash.

## Why this fork

- Provides option to override version(and versionHash)
- nixpkgs currently doesnt provide godot4 with mono
- Quick tests show it actually works ;)
- Icon/Desktop/Man files pinned to actual commit link instead of master branch, so won't error when Godot repo gets updated.