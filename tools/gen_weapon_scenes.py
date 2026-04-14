"""Regenerate `weapons/scenes/weapon_<id>.tscn` from `PlayerLoadoutRegistry` IDs."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "weapons" / "scenes"

IDS = [
    "bullet",
    "aura",
    "chain",
    "boomerang",
    "lightning",
    "ice_ball",
    "shadow",
    "laser",
    "holy_bullet",
    "toxic_chain",
    "death_laser",
    "blood_boomerang",
    "storm",
    "shadow_storm",
    "frost_nova",
    "fan_blade",
    "ember_fan",
    "hex_sigil",
    "binding_circle",
    "gravity_anchor",
    "void_lens",
    "bastion_flail",
    "citadel_flail",
    "shield_ram",
    "fortress_ram",
]


def pascal(s: str) -> str:
    return "".join(w.title() for w in s.split("_"))


SUB = """[sub_resource type="CircleShape2D" id="CircleShape2D_placeholder"]
radius = 28.0
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for wid in IDS:
        node = "Weapon" + pascal(wid)
        script = f"res://weapons/weapon_{wid}.gd"
        body = f"""[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="{script}" id="1_script"]

{SUB}
[node name="{node}" type="Area2D"]
collision_layer = 0
collision_mask = 0
monitoring = false
monitorable = false
script = ExtResource("1_script")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D_placeholder")

[node name="ColorRect" type="ColorRect" parent="."]
layout_mode = 0
visible = false
offset_left = -40.0
offset_top = -40.0
offset_right = 40.0
offset_bottom = 40.0
color = Color(0.45, 0.85, 1, 0.18)

[node name="Sprite2D" type="Sprite2D" parent="."]
visible = false
"""
        (OUT / f"weapon_{wid}.tscn").write_text(body, encoding="utf-8", newline="\n")
    print("wrote", len(IDS), "scenes to", OUT)


if __name__ == "__main__":
    main()
