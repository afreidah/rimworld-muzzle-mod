#!/usr/bin/env bash

###########################################################################################
# --------------------------------------------------------------------------------------- #
#  🐾 RimWorld Nuzzler Mod Generator (Advanced Version)                                   #
# --------------------------------------------------------------------------------------- #
#  This script generates a RimWorld mod that enables the "nuzzling" behavior for animals  #
#  by injecting the `nuzzleMtbHours` XML field into their <race> definitions.             #
#                                                                                         #
#  NEW FEATURE:                                                                           #
#   ✔ Supports setting a custom nuzzle interval per animal (in in-game hours) via args!   #
#                                                                                         #
#  WHAT IT DOES:                                                                          #
#   ✔ Creates a valid RimWorld mod folder structure in your system's Mods/ directory:     #
#       Mods/<ModName>/                                                                   #
#         ├── About/About.xml             → Metadata declaring the mod                    #
#         └── Patches/NuzzlePatches.xml   → Adds <nuzzleMtbHours> to animals              #
#                                                                                         #
#  WHAT IS `nuzzleMtbHours`?                                                              #
#   → Mean Time Between nuzzling, in in-game hours. Lower = more frequent.                #
#   → RimWorld uses this to probabilistically trigger nuzzles from animals to humans.     #
#                                                                                         #
#  USAGE:                                                                                 #
#    ./gen_nuzzler.sh <ModName> <Animal[:Hours]> [More...]                                #
#                                                                                         #
#  EXAMPLES:                                                                              #
#    ./gen_nuzzler.sh ZooSnugglers Muffalo:12 Elephant:36 Chicken                         #
#     → Muffalo nuzzles every 12 hours, Elephant every 36, Chicken defaults to 24         #
#                                                                                         #
#  NOTE: This script writes directly into your RimWorld Mods folder so it's ready to go.  #
# --------------------------------------------------------------------------------------- #
###########################################################################################

# --- Exit immediately on error, undefined variables, or failed pipelines ---
set -euo pipefail

# --- Function to detect the RimWorld Mods directory based on the OS ---
detect_mods_dir() {
  case "$OSTYPE" in
    msys*|cygwin*|win32)
      # --- For Git Bash or similar on Windows, navigate up from %APPDATA% to get to the LocalLow path ---
      echo "$APPDATA/../LocalLow/Ludeon Studios/RimWorld by Ludeon Studios/Mods"
      ;;
    darwin*)
      # --- macOS default Mods folder location ---
      echo "$HOME/Library/Application Support/RimWorld/Mods"
      ;;
    linux*)
      # --- Linux default Mods folder location ---
      echo "$HOME/.config/unity3d/Ludeon Studios/RimWorld/Mods"
      ;;
    *)
      # --- Failsafe for unsupported platforms ---
      echo "Unsupported OS: $OSTYPE" >&2
      exit 1
      ;;
  esac
}

# --- First argument is the mod name (e.g., "SnugglyPack") ---
MOD_NAME="$1"
shift

# --- Remaining arguments are the animal list (with optional ":hours" suffixes) ---
ANIMALS=("$@")

# --- Ensure a mod name and at least one animal were provided ---
if [[ -z "$MOD_NAME" || "${#ANIMALS[@]}" -eq 0 ]]; then
  echo "Usage: $0 <ModName> <Animal[:Hours]> [Animal2[:Hours] ...]"
  exit 1
fi

# --- Determine platform-specific Mods folder path ---
MODS_DIR="$(detect_mods_dir)"

# --- Build full path to this specific mod’s folder ---
MOD_DIR="$MODS_DIR/$MOD_NAME"
ABOUT_DIR="$MOD_DIR/About"
PATCH_DIR="$MOD_DIR/Patches"

# --- Inform the user where the mod will be written ---
echo "Writing mod to: $MOD_DIR"

# --- Create required directory structure for RimWorld mod ---
mkdir -p "$ABOUT_DIR" "$PATCH_DIR"

# --- Generate About.xml which declares metadata to RimWorld ---
cat > "$ABOUT_DIR/About.xml" <<EOF
<ModMetaData>
  <name>$MOD_NAME</name>
  <author>YourName</author>
  <description>Auto-generated mod that adds nuzzling behavior to animals.</description>
  <packageId>com.yourname.$(echo "$MOD_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:].-')</packageId>
  <supportedVersions>
    <li>1.5</li>
  </supportedVersions>
</ModMetaData>
EOF

# --- Begin writing the root of NuzzlePatches.xml which defines the patch instructions ---
cat > "$PATCH_DIR/NuzzlePatches.xml" <<EOF
<Patch>
EOF

# --- Loop through each animal:hours pair and write a PatchOperationAdd block ---
for ENTRY in "${ANIMALS[@]}"; do
  # --- Split on ":" into animal and optional nuzzle hour value ---
  IFS=":" read -r ANIMAL HOURS <<< "$ENTRY"

  # --- If no hours specified, default to 24 (once per in-game day) ---
  HOURS="${HOURS:-24}"

  # --- Append a patch operation block for this animal ---
  cat >> "$PATCH_DIR/NuzzlePatches.xml" <<EOF
  <Operation Class="PatchOperationAdd">
    <xpath>Defs/ThingDef[defName="$ANIMAL"]/race</xpath>
    <value>
      <nuzzleMtbHours>$HOURS</nuzzleMtbHours>
    </value>
  </Operation>
EOF
done

# --- Close the root <Patch> tag in the XML file ---
echo "</Patch>" >> "$PATCH_DIR/NuzzlePatches.xml"

# --- Final confirmation message to user ---
echo "Mod '$MOD_NAME' successfully created in your RimWorld Mods folder!"

