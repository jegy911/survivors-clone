# Yeni kahraman talebi — zorunlu paket (Ironfall)

Oyuncu **yalnızca bir sınıf adı** (ör. «mage için yeni karakter») dediğinde bile aşağıdaki paket **tek seferde** tamamlanmalıdır. Bu dosya, o talebin **tam kapsamını** tanımlar; ajan ve geliştirici buradan okur.

---

## 1. Kahraman

- `CharacterData.CHARACTERS` içinde **benzersiz `id`**, istenen **`hero_class`**, oyun içi **kimlik olarak diğer kahramanlardan ayrışan** kit (istatistik / `origin_bonus` / açılış koşulu / maliyet).
- Aynı sınıftaki veya rostergenelindeki **mevcut bir kahramanın kopyası gibi** hissettirmemeli: başlangıç silahı, ritim, risk/ödül veya oynanış vurgusu farklı olmalı.
- `characters/<id>/<id>.tscn` — kendi sahnesi; başka tscn kopyalanıyorsa **SpriteFrames animasyon isimleri** korunur, frame içerikleri sonradan temizlenebilir (`GELISTIRICI_REHBERI.md`).

---

## 2. Zorunlu içerik üçlüsü (aynı talepte)

| Parça | Zorunlu | Not |
|--------|---------|-----|
| **Yeni silah** | Evet | `weapons/weapon_<id>.gd`, gerekirse `weapons/scenes/weapon_<id>.tscn`, `PlayerLoadoutRegistry`, `player._LEVELUP_WEAPON_IDS`, `upgrade_ui.WEAPON_UPGRADE_IDS`, `CollectionData.WEAPON_ENTRIES`, `locales/en.json` (`codex.weapon`, `loadout_weapons`), istenirse `codex_extensions_en.json`. |
| **Yeni pasif eşya** | Evet | `items/item_<id>.gd`, aynı kayıt zincirinde **item** havuzları + kodeks. **Başlangıçta `start_item` boş** kalır; eşya koşuda level-up / sandık ile gelir (proje kuralı). |
| **Yeni evrim** | Evet | `WeaponEvolution.EVOLUTIONS` içinde **yalnızca bu silah + bu eşya** (ikisi de MAX) ile oluşan tarife; evrim silahı yeni bir `weapon_<evo>.gd` (+ sahne, registry, kodeks, `ui.evolution_defs.<evo>`). |

Evrim **başka** silah/eşya çiftini kopyalamamalı; yeni kahramanın anlatısı bu üçlü üzerinden okunmalıdır.

---

## 3. Kontrol listesi (PR öncesi)

- [ ] `CharacterData.CHARACTER_SCENE_BY_ID` + gerekirse `SaveManager.OLD_CHARACTER_ORDER` sonuna `id`.
- [ ] `player.gd` havuzları + `random_weapons` (varsa) güncel.
- [ ] `upgrade_ui.gd` glyph sözlükleri (yeni id’ler için).
- [ ] `docs/KARAKTER_SINIFLARI_VE_TASARIM.md` tablo / sayım (sınıf adedi).
- [ ] `locales/en.json` — yalnızca İngilizce anahtarlar (diğer diller dondurulduysa dokunma).

---

## 4. Örnek (referans): `arcanist`

- Silah: **`arc_pulse`** (Ark Halkası — donut bant hasarı).  
- Eşya: **`field_lens`** (Alan Merceği — Area% katkısı, `player.get_area_multiplier()`).  
- Evrim: **`arc_surge`** ← `arc_pulse` MAX + `field_lens` MAX.

Bu paket, «sadece karakter» ile yetinmeyen talepler için **referans uygulama**dır.
