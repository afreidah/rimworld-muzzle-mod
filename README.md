# 🐾 RimWorld Nuzzler Mod Generator

A Bash script to quickly generate a RimWorld mod that enables the "nuzzling" behavior for any animals you choose, with customizable nuzzle intervals.

## What does it do?

- Creates a RimWorld mod folder in your system's Mods directory.
- Adds the `<nuzzleMtbHours>` XML field to the `<race>` definition of each specified animal, enabling nuzzling.
- Lets you set a custom nuzzle interval (in in-game hours) per animal.

## What is `nuzzleMtbHours`?

- Stands for "Mean Time Between nuzzling" (in in-game hours).
- Lower values = more frequent nuzzling.
- RimWorld uses this to probabilistically trigger nuzzles from animals to humans.

## Usage

```sh
./gen_nuzzler.sh <ModName> <Animal[:Hours]> [Animal2[:Hours] ...]
```

- `<ModName>`: Name of your mod (folder will be created).
- `<Animal>`: Animal defName (e.g., Muffalo).
- `:Hours` (optional): Nuzzle interval in hours (default: 24).

## Example

```sh
./gen_nuzzler.sh ZooSnugglers Muffalo:12 Elephant:36 Chicken
```
- Muffalo nuzzles every 12 hours, Elephant every 36, Chicken defaults to 24.

## Notes

- The script auto-detects your RimWorld Mods folder (Windows, macOS, Linux).
- Mod is ready to use immediately after running the script.
