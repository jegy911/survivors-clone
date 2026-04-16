Level-up / inventory icons (PNG)
==================================
Put square PNGs here (e.g. 64x64 or 128x128). Transparent background recommended.
If a file is missing, the UI keeps the emoji fallback.

Layout (paths are also in code: core/upgrade_icon_catalog.gd):

  res://assets/ui/upgrade_icons/weapons/<id>.png
  res://assets/ui/upgrade_icons/items/<id>.png
  res://assets/ui/upgrade_icons/evolutions/<evo_id>.png
  res://assets/ui/upgrade_icons/stats/<stat_id>.png

Weapon IDs (base pool + evolution results use "weapons" for the result weapon id when it is a normal weapon id; evolution-only results are under "evolutions"):

  weapons/: bullet, dagger, aura, chain, boomerang, lightning, ice_ball, shadow, laser, fan_blade,
            hex_sigil, gravity_anchor, bastion_flail, shield_ram,
            holy_bullet, toxic_chain, death_laser, blood_boomerang, storm, shadow_storm, frost_nova,
            ember_fan, binding_circle, void_lens, citadel_flail, fortress_ram, veil_daggers

Evolution cards (pick row uses evolutions/ when the offer is an evolution):

  evolutions/: holy_bullet, toxic_chain, death_laser, blood_boomerang, storm, shadow_storm, frost_nova,
              ember_fan, binding_circle, void_lens, citadel_flail, fortress_ram, veil_daggers

  (You may use the same art for weapons/<id> and evolutions/<id> if identical.)

Item IDs:

  items/: lifesteal, armor, crit, explosion, magnet, poison, shield, speed_charm, blood_pool,
         luck_stone, turbine, steam_armor, energy_cell, ember_heart, glyph_charm, resonance_stone,
         rampart_plate, iron_bulwark, night_vial

Stat upgrade cards (optional):

  stats/: speed, max_hp, heal

After adding PNGs: Godot → Project → Reload Current Project (or restart editor) so import runs.
