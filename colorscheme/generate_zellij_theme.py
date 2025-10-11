#!/usr/bin/env python3

import tomllib
import os
import sys


def hex_to_rgb_str(hex_color):
    """Converts a hex color string to an RGB string 'r g b'."""
    if hex_color == "0":
        return "0"
    hex_color = hex_color.lstrip("#")
    if len(hex_color) != 6:
        raise ValueError(f"Invalid hex color format: '{hex_color}'")
    return " ".join(str(int(hex_color[i : i + 2], 16)) for i in (0, 2, 4))


def main():
    """
    Generates the Zellij theme from the colors.toml file.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    colors_file = os.path.join(project_root, "colorscheme", "colors.toml")
    zellij_theme_file = os.path.join(project_root, "my-zellij-theme.kdl")

    try:
        with open(colors_file, "rb") as f:
            colors = tomllib.load(f)
    except FileNotFoundError:
        print(f"Error: '{colors_file}' not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error parsing TOML file: {e}", file=sys.stderr)
        sys.exit(1)

    zellij_colors = colors.get("zellij", {})
    if not zellij_colors:
        print("Error: [zellij] section not found in colors.toml.", file=sys.stderr)
        sys.exit(1)

    c = {}
    try:
        for name, value in zellij_colors.items():
            c[name] = hex_to_rgb_str(value)
    except ValueError as e:
        print(f"Error converting hex to RGB: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        theme_template = f"""
themes {{
    my-theme {{
        text_unselected {{
            base {c["text_unselected_base"]}
            background {c["text_unselected_background"]}
            emphasis_0 {c["text_unselected_emphasis_0"]}
            emphasis_1 {c["text_unselected_emphasis_1"]}
            emphasis_2 {c["text_unselected_emphasis_2"]}
            emphasis_3 {c["text_unselected_emphasis_3"]}
        }}
        text_selected {{
            base {c["text_selected_base"]}
            background {c["text_selected_background"]}
            emphasis_0 {c["text_selected_emphasis_0"]}
            emphasis_1 {c["text_selected_emphasis_1"]}
            emphasis_2 {c["text_selected_emphasis_2"]}
            emphasis_3 {c["text_selected_emphasis_3"]}
        }}
        ribbon_selected {{
            base {c["ribbon_selected_base"]}
            background {c["ribbon_selected_background"]}
            emphasis_0 {c["ribbon_selected_emphasis_0"]}
            emphasis_1 {c["ribbon_selected_emphasis_1"]}
            emphasis_2 {c["ribbon_selected_emphasis_2"]}
            emphasis_3 {c["ribbon_selected_emphasis_3"]}
        }}
        ribbon_unselected {{
            base {c["ribbon_unselected_base"]}
            background {c["ribbon_unselected_background"]}
            emphasis_0 {c["ribbon_unselected_emphasis_0"]}
            emphasis_1 {c["ribbon_unselected_emphasis_1"]}
            emphasis_2 {c["ribbon_unselected_emphasis_2"]}
            emphasis_3 {c["ribbon_unselected_emphasis_3"]}
        }}
        table_title {{
            base {c["table_title_base"]}
            background {c["table_title_background"]}
            emphasis_0 {c["table_title_emphasis_0"]}
            emphasis_1 {c["table_title_emphasis_1"]}
            emphasis_2 {c["table_title_emphasis_2"]}
            emphasis_3 {c["table_title_emphasis_3"]}
        }}
        table_cell_selected {{
            base {c["table_cell_selected_base"]}
            background {c["table_cell_selected_background"]}
            emphasis_0 {c["table_cell_selected_emphasis_0"]}
            emphasis_1 {c["table_cell_selected_emphasis_1"]}
            emphasis_2 {c["table_cell_selected_emphasis_2"]}
            emphasis_3 {c["table_cell_selected_emphasis_3"]}
        }}
        table_cell_unselected {{
            base {c["table_cell_unselected_base"]}
            background {c["table_cell_unselected_background"]}
            emphasis_0 {c["table_cell_unselected_emphasis_0"]}
            emphasis_1 {c["table_cell_unselected_emphasis_1"]}
            emphasis_2 {c["table_cell_unselected_emphasis_2"]}
            emphasis_3 {c["table_cell_unselected_emphasis_3"]}
        }}
        list_selected {{
            base {c["list_selected_base"]}
            background {c["list_selected_background"]}
            emphasis_0 {c["list_selected_emphasis_0"]}
            emphasis_1 {c["list_selected_emphasis_1"]}
            emphasis_2 {c["list_selected_emphasis_2"]}
            emphasis_3 {c["list_selected_emphasis_3"]}
        }}
        list_unselected {{
            base {c["list_unselected_base"]}
            background {c["list_unselected_background"]}
            emphasis_0 {c["list_unselected_emphasis_0"]}
            emphasis_1 {c["list_unselected_emphasis_1"]}
            emphasis_2 {c["list_unselected_emphasis_2"]}
            emphasis_3 {c["list_unselected_emphasis_3"]}
        }}
        frame_selected {{
            base {c["frame_selected_base"]}
            background {c["frame_selected_background"]}
            emphasis_0 {c["frame_selected_emphasis_0"]}
            emphasis_1 {c["frame_selected_emphasis_1"]}
            emphasis_2 {c["frame_selected_emphasis_2"]}
            emphasis_3 {c["frame_selected_emphasis_3"]}
        }}
        frame_highlight {{
            base {c["frame_highlight_base"]}
            background {c["frame_highlight_background"]}
            emphasis_0 {c["frame_highlight_emphasis_0"]}
            emphasis_1 {c["frame_highlight_emphasis_1"]}
            emphasis_2 {c["frame_highlight_emphasis_2"]}
            emphasis_3 {c["frame_highlight_emphasis_3"]}
        }}
        exit_code_success {{
            base {c["exit_code_success_base"]}
            background {c["exit_code_success_background"]}
            emphasis_0 {c["exit_code_success_emphasis_0"]}
            emphasis_1 {c["exit_code_success_emphasis_1"]}
            emphasis_2 {c["exit_code_success_emphasis_2"]}
            emphasis_3 {c["exit_code_success_emphasis_3"]}
        }}
        exit_code_error {{
            base {c["exit_code_error_base"]}
            background {c["exit_code_error_background"]}
            emphasis_0 {c["exit_code_error_emphasis_0"]}
            emphasis_1 {c["exit_code_error_emphasis_1"]}
            emphasis_2 {c["exit_code_error_emphasis_2"]}
            emphasis_3 {c["exit_code_error_emphasis_3"]}
        }}
        multiplayer_user_colors {{
            player_1 {c["multiplayer_user_colors_player_1"]}
            player_2 {c["multiplayer_user_colors_player_2"]}
            player_3 {c["multiplayer_user_colors_player_3"]}
            player_4 {c["multiplayer_user_colors_player_4"]}
            player_5 {c["multiplayer_user_colors_player_5"]}
            player_6 {c["multiplayer_user_colors_player_6"]}
            player_7 {c["multiplayer_user_colors_player_7"]}
            player_8 {c["multiplayer_user_colors_player_8"]}
            player_9 {c["multiplayer_user_colors_player_9"]}
            player_10 {c["multiplayer_user_colors_player_10"]}
        }}
    }}
}}
"""
    except KeyError as e:
        print(
            f"Error: Color key '{e.args[0]}' not found in [zellij] section of colors.toml",
            file=sys.stderr,
        )
        sys.exit(1)

    with open(zellij_theme_file, "w") as f:
        f.write(theme_template.strip())

    print(f"Successfully generated '{zellij_theme_file}'")


if __name__ == "__main__":
    main()
