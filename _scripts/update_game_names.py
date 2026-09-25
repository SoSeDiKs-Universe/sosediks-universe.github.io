"""Extracts block, item and entity names from Minecraft's lang files into _data/game_names/<lang>.json.

These names are used by the symlink plugin, e.g. for tooltips of grouped icons.

Usage: python3 _scripts/update_game_names.py <path to assets/minecraft/lang>
"""
import json
import pathlib
import re
import sys

LANGS = {"en": "en_us", "ru": "ru_ru", "uk": "uk_ua"}
# Plain names, plus potion-based variants like "item.minecraft.tipped_arrow.effect.poison"
NAME_KEY = re.compile(r"(block|item|entity)\.minecraft\.[a-z0-9_]+(\.effect\.[a-z0-9_]+)?")

lang_dir = pathlib.Path(sys.argv[1])
out_dir = pathlib.Path(__file__).resolve().parent.parent / "_data" / "game_names"
out_dir.mkdir(parents=True, exist_ok=True)

for lang, file in LANGS.items():
    names = json.loads((lang_dir / f"{file}.json").read_text(encoding="utf-8"))
    names = {key: value for key, value in sorted(names.items()) if NAME_KEY.fullmatch(key)}
    (out_dir / f"{lang}.json").write_text(json.dumps(names, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"{lang}: {len(names)} names")
