# ColorRect — hızlı takip

**Kullanım (silah / kahraman / eşya):** **Kart ✓ ve oyun-içi görsel ✓** aynı satırda ise o silah satırını bu tablolardan **sil**; silah `id`’sini aşağıdaki **Son tarama** listesine ekle. Kısmi gap (ör. ✓|✗) **satırda kalır**. Yeni gap açılırsa satır **ekle**. Detay: `docs/TASARIM.md`. SFX: `docs/sesler-muzikler-efektler.md`.

**Dünya, orb, sandık, environment spawn:** Tam liste ve XP **3 tür** tasarım hedefi — **`docs/TASARIM.md` → bölüm «Pickup, orb ve dünya objeleri»** (aşağıda sadece özet).

**İşaretler:** ✓ = var (dosya veya anlamlı oyun-içi görsel), ✗ = yok / henüz yok.

**Not:** Kahraman sahnelerinde kök `ColorRect` çoğunlukla `player.gd` gövde rengi; bu dosya özellikle **eksik ikon** ve **eksik oyun-içi silah/eşya görseli** takibi içindir.

---

## Kahraman

| Karakter ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------------|-------------------|-----------------|
| *(şu an açık gap yok)* | — | — |

**Kart / kodeks ikon:** `res://assets/ui/character_icons/<id>.png`, `res://characters/<id>/codex.png`, `res://assets/ui/codex_icons/...` vb. (`CodexIconCatalog` / `UpgradeIconCatalog` sırasıyla dener).

**Oyun-içi görsel:** `AnimatedSprite2D` + dolu frame / karakter dokuları (`assets/character assets/...`); burada satır yoksa hepsi bu anlamda kapsanıyor sayılır.

---

## Silah sahneleri (`weapons/scenes/`)

**Silah ID:** dosya adından `weapon_` önekini ve `.tscn` uzantısını çıkar → örn. `weapon_bastion_flail.tscn` → `bastion_flail` → ikon yolu `res://assets/ui/upgrade_icons/weapons/bastion_flail.png`; yoksa `.../evolutions/<aynı_id>.png` (`arc_surge` gibi). Kod: `UpgradeIconCatalog.try_weapon_with_evolution_fallback`.

**Kart / kodeks ikon:** yukarıdaki PNG gerçekten var mı (evrim silahlarında çoğunlukla `evolutions/`).

**Oyun-içi görsel:** `assets/projectiles/...`, anlamlı `Sprite2D` + doku (sahne veya kod), veya `projectiles/*.tscn` içi sprite; **runtime** olarak ana dünyaya eklenen tekillik / mermi sprite’ı da ✓ (ör. `weapons/center_cataclysm_helper.gd`). Yalnızca gizli `ColorRect` + anlamlı sprite/hitbox yok + saf yarıçap hasarı ✗ sayılır.

Evrim kimlikleri tek kaynak: `weapons/weapon_evolution.gd` → `EVOLUTIONS`.

### Taban silahlar

Level-up havuzundan doğrudan seçilen / evrim **sonucu olmayan** silah sahneleri — **yalnızca en az bir ✗ kalanlar** (ikisi ✓ olunca satır silinir).

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| *(taban gap yok)* | — | — | — |

### Evrim silahları

Yalnızca `EVOLUTIONS` ile elde edilen silah id’leri — **yalnızca en az bir ✗ kalanlar**.

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| `weapon_binding_circle.tscn` | binding_circle | ✓ | ✗ (alan hasarı; `projectiles/binding_circle/glyph.png` envanter, sahada özel mesh yok) |
| `weapon_citadel_flail.tscn` | citadel_flail | ✓ | ✗ (aynı; `citadel_flail/head.png` envanter) |

**Son tarama (kart ✓ + oyun-içi ✓ — yukarıdaki gap tablolarında artık satır yok):**

- **Taban:** `arc_pulse`, `aura`, `bullet`, `chain`, `boomerang`, `dagger`, `fan_blade`, `hex_sigil`, `ice_ball`, `laser`, `lightning`, `shadow`, `shield_ram`, `bastion_flail`, `gravity_anchor`
- **Evrim:** `arc_surge`, `blood_boomerang`, `death_laser`, `ember_fan`, `fortress_ram`, `frost_nova`, `holy_bullet`, `shadow_storm`, `storm`, `toxic_chain`, `veil_daggers`, `void_lens`

Runtime `ColorRect` / geçici blok (sahne `.tscn` dışı, “kalıcı sanat” değil): `weapon_shadow.gd`.

---

## Eşyalar (`items/` — sahne yok, script + ikon)

Pasif eşyalar `items/item_<id>.gd` ile yüklenir; **`.tscn` yok**. İleride dünyada görünür efekt / özel doku eklendikçe **Oyun-içi görsel** sütununu güncelle.

**Kart / kodeks ikon:** `res://assets/ui/upgrade_icons/items/<id>.png` (`UpgradeIconCatalog.try_item`).

**Oyun-içi görsel:** Oyunda dünyaya eklenen görünür node / partikül / özel efekt doku yolu (yalnızca sayısal pasif etki ✗).

**İşlev / görev:** Pasifin oyunda yaptığı iş (kısa özet; ayrıntı `items/item_<id>.gd` ve locale metinleri).

| Eşya ID | İşlev / görev | Kart / kodeks ikon | Oyun-içi görsel |
|---------|----------------|-------------------|-----------------|
| lifesteal | Verilen hasarın bir kısmı kadar can (vuruş başına) | ✓ | ✗ |
| armor | Alınan hasarı zırh değeriyle azaltma | ✓ | ✗ |
| crit | Kritik vuruş şansı; krit çarpanı | ✓ | ✗ |
| explosion | Düşman ölünce şansla alan hasarı patlaması | ✓ | ✓ (`explosion_burst.png` patlama anı) |
| magnet | XP orb çekim menzili artışı | ✓ | ✗ |
| poison | Vuruşta düşmana zehir DoT uygulama | ✓ | ✗ |
| shield | Bekleme sonrası tek seferlik hasar absorbe (kalkan) | ✓ | ✗ |
| speed_charm | Düşman öldürünce geçici hareket hızı | ✓ | ✓ (`speed_charm_effect.png`, boost + yürürken ayak altı) |
| blood_pool | Öldürünce şansla süreli alan DoT | ✓ | ✓ (`blood_pool_ripple.png` havuzu) |
| luck_stone | Ek krit şansı + altın toplama bonusu | ✓ | ✗ |
| turbine | Son hareket süresine göre biriken hasar bonusu | ✓ | ✗ |
| steam_armor | Hasar alınca kısa yenilmezlik, sonra bekleme | ✓ | ✗ |
| energy_cell | Periyodik: tüm silahları anında ateş + ardından geçici yavaş cooldown | ✓ | ✗ |
| ember_heart | Düşman öldürünce sabit can iyileşmesi | ✗ | ✗ |
| glyph_charm | Alınan hasara ek «ward» / zırh katkısı (`take_damage`) | ✗ | ✗ |
| resonance_stone | XP + altın pickup çekim yarıçapı (magnet bonusu ile toplanır) | ✗ | ✗ |
| rampart_plate | Ek zırh değeri (savunma) | ✗ | ✗ |
| iron_bulwark | Düz (flat) hasar kesintisi | ✗ | ✗ |
| night_vial | Hafif pickup çekim yarıçapı (evrim yolu / loadout) | ✗ | ✗ |
| field_lens | Alan ölçekli silahlara `%` alan bonusu (`get_area_multiplier`) | ✓ | ✗ |

---

## Dünya / spawn cisimleri — oyun-içi görsel bacağı (özet)

*(Olasılık, kod: `TASARIM` ana tablo. Görsel sütununda: ✗ = ileride değiştirilecek placeholder.)*

| Cisim / sistem | İşlev / görev | Görsel durum (kısa) | Kod / not |
|----------------|--------------|--------------------|-----------|
| **XP 1× / 3× / 8×** (3 tür) | Oyuncu topladıkça **seviye XP** verir (1×, 3× veya 8×; co-op’ta diğer oyuncu yarım pay). P2’ye sızma: `xp_orb.gd`. | `xp.png` / `green_xp.png` / `red_xp.png` (`xp_orb` tier) | `enemy_base.gd` `_spawn_xp_orb_drop` |
| Altın küre | **Altın** toplama; miktar (elite vb.) + şans/ meta bonusları ile. | Doku var; anim/parıltı açık | `gold_orb` |
| Sandık | Yaklaşınca açılır: **rastgele eşya**, veya **altın**, veya **%15 can**; istat: `chests_opened`. | ColorRect; ritüel sanat açık | `chest.gd` |
| Kan yemini (Blood Oath) | **Solo:** +25 altın. **Co-op:** iki oyuncu yeterince yakınsa **kan yemini** buff’ı (`activate_blood_oath`); değilse yine altın uyarısı. | ColorRect | `blood_oath` |
| Dişli parçası (Cog) | Sınır varken **cog toplar**; cog ekonomisi/ilerleme (limit `can_collect_more` ile). | `cog.png` sprite | `cog_shard` |
| Zaman dişlisi | Toplanınca **tüm düşmanları 10 sn dondurur** (slow tam). | `time_gear_icon.png` sprite | `time_gear.gd` |
| Buhar bombası | Toplanınca **sahadaki normal düşmanları** öldürür (boss hariç); öldürme sayısı metni. | `steam_bomb_icon.png` sprite | `steam_bomb.gd` |
| Vakum toplayıcı | Alana giren: ekrandaki tüm **XP** ve **altın** orblarına vakum çekimi (`vacuum_attract`); kısa süre sonra kaybolur. | Cyan kare (runtime) | `environment_manager` |
| Buz fıçısı (freeze) | Mermi tetikler: alanda **yavaşlatma** yayan patlama (büyük mavi alan). | Varil `freeze_barrel_icon` + patlama `freeze_burst` | `freeze_barrel` |
| Zehir tuzağı | Mermi tetikler: alana **zehir DoT** bırakan bulut. | Kare + alan | `poison_trap` |
| Risk sunağı | Rastgele: **%200 XP+altın**, düşman hız/yoğunluk maliyeti (~60 s); “risk” türü. | Kare + `⚠` | `shrine_of_risk` |
| Şeytan sunağı | Rastgele: **%35 can** gider, karşılığı **rastgele silah veya eşyayı** max yapar. | Kare + `☠` | `shrine_of_risk` |
| Kırılabilir kutu (crate) | Mermi kırar (3 isabet); ödül: kısa **bounce mermi**, hız, hasar, iyileşme (rastgele). | ColorRect’ler | `destructible_crate` |
| Enkaz (ruin cache) | Açınca: yükseltilmeye uygun **silah veya eşya** +1 seviye, yoksa +50 **altın**. | Brown/gold rekt | `environment_manager` `_spawn_ruin_cache` |
| Yuzen hasar metni | Vuruş/iyileşme sayısını ekranda gösterir. | Tema / kritik ayrımı açık | `damage_number` |
| Düşman mermileri + oyuncu mermileri | Hasar iletir; tür `TASARIM` «Projectile». | Bir kısmı kısmi / final açık | `projectiles/*.tscn` |
| Pasif eşyalar (dünya) | `blood_pool` vb.: çoğunluk sadece **veri/ColorRect** proc; ayrı mesh yok. | Üstte eşya tablosu | `items/*` |
