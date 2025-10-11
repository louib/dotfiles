#!/usr/bin/env python3
"""
A script to visualize and compare versions of a colors.toml file.

By default, it compares the version at GIT HEAD with the current working
directory version to show uncommitted changes.
"""

import tomllib
import subprocess
import sys
from pathlib import Path


def hex_to_rgb(hex_color):
    """Converts a hex color string to an (r, g, b) tuple."""
    hex_color = hex_color.lstrip("#")
    if len(hex_color) != 6:
        return 0, 0, 0
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def rgb_to_ansi_bg(r, g, b):
    """Converts an RGB tuple to an ANSI background color escape code."""
    return f"\033[48;2;{r};{g};{b}m"


def color_swatch(hex_color):
    """Returns a colored swatch string '  ' for the terminal."""
    if not hex_color:
        return "  "
    r, g, b = hex_to_rgb(hex_color)
    return f"{rgb_to_ansi_bg(r, g, b)}  \033[0m"


def get_git_content(revision, file_path):
    """Gets the content of a file from a specific git revision."""
    try:
        # Use Path objects to construct the git path specifier
        git_path = Path(file_path).as_posix()
        result = subprocess.run(
            ["git", "show", f"{revision}:{git_path}"],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8",
        )
        return result.stdout
    except subprocess.CalledProcessError:
        return ""  # File might not exist in the old revision


def get_local_content(file_path):
    """Gets the content of a local file."""
    path = Path(file_path)
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def parse_colors(content):
    """Parses TOML content into a flat dictionary of {'section.key': 'hex'}."""
    if not content:
        return {}
    try:
        data = tomllib.loads(content)
        flat_colors = {}
        for section, values in data.items():
            if isinstance(values, dict):
                for key, color in values.items():
                    if isinstance(color, str):
                        flat_colors[f"{section}.{key}"] = color.strip("'\"")
        return flat_colors
    except tomllib.TOMLDecodeError as e:
        print(f"Error parsing TOML: {e}", file=sys.stderr)
        return {}


def print_comparison(old_colors, new_colors, width):
    """Prints a side-by-side comparison of two color dictionaries."""
    all_keys = sorted(list(set(old_colors.keys()) | set(new_colors.keys())))
    current_section = None

    for key in all_keys:
        section, name = key.split(".", 1)
        if section != current_section:
            print(f"\n[{section}]")
            current_section = section

        old_hex = old_colors.get(key)
        new_hex = new_colors.get(key)

        if old_hex == new_hex:
            swatch = color_swatch(new_hex)
            print(f"  {name: <{width}} {swatch} #{new_hex}")
        elif old_hex and new_hex:
            print(f"  {name: <{width}} \033[33m(modified)\033[0m")
            old_swatch = color_swatch(old_hex)
            new_swatch = color_swatch(new_hex)
            print(f"    - HEAD:    {old_swatch} #{old_hex}")
            print(f"    + Current: {new_swatch} #{new_hex}")
        elif not old_hex and new_hex:
            swatch = color_swatch(new_hex)
            print(f"  {name: <{width}} {swatch} #{new_hex} \033[32m(added)\033[0m")
        elif old_hex and not new_hex:
            swatch = color_swatch(old_hex)
            print(f"  {name: <{width}} {swatch} #{old_hex} \033[31m(removed)\033[0m")


def main():
    """Main script execution."""
    try:
        script_dir = Path(__file__).parent.resolve()
        # Assume the script is in a subdirectory of the repo root
        repo_root = script_dir.parent
        color_file_rel_path = script_dir.relative_to(repo_root) / "colors.toml"
        color_file_abs_path = script_dir / "colors.toml"
    except ValueError:
        print("Error: Could not determine repository structure.", file=sys.stderr)
        sys.exit(1)

    rev1 = "HEAD"
    print(f"Comparing colors for '{color_file_rel_path}'")
    print(f"(-) = {rev1}    (+) = Current changes\n")

    head_content = get_git_content(rev1, color_file_rel_path)
    local_content = get_local_content(color_file_abs_path)

    if not local_content:
        print(
            f"Error: Local file not found at '{color_file_abs_path}'", file=sys.stderr
        )
        sys.exit(1)

    head_colors = parse_colors(head_content)
    local_colors = parse_colors(local_content)

    all_keys = set(head_colors.keys()) | set(local_colors.keys())
    if not all_keys:
        print("No colors found to compare.")
        return

    # Calculate the optimal width for the name column
    max_name_len = max(len(key.split(".", 1)[1]) for key in all_keys)
    width = max_name_len + 2  # Add a little padding

    print_comparison(head_colors, local_colors, width)


if __name__ == "__main__":
    main()
