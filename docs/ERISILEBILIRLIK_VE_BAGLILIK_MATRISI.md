# Erişilebilirlik ve bağlılık (dopamin döngüsü) — tam matris

Bu belge, ürün taslağındaki **20+20 maddeyi** Ironfall kod tabanıyla **eşleştirir**.  
Sütun **Durum**: **Var** (karşılanıyor) | **Kısmi** (bir kısmı var veya hedef tam örtüşmüyor) | **Yok** (henüz yok / plan dışı).

**Son kod kontrolü:** 2026-04-05

İlgili kısa checklist: `docs/YOL_HARITASI.md` (özet).  
Ayar anahtarları teknik özeti: `docs/GELISTIRICI_REHBERI.md` §15.

---

## Tablo 1 — Erişilebilirlik (20 madde)

| # | Madde | Kısa açıklama | Detaylı açıklama (özet) | Oyuna uyarlama (özet) | Önem (1–10) | Geliştirilebilirlik | **Durum** | **Repo kontrolü** |
|---|--------|---------------|---------------------------|-------------------------|-------------|---------------------|----------|-------------------|
| 1 | Oto-Ateş | Nişanı oyuna bırak. | Pozisyon + strateji; mekanik yük azalır. | Cooldown dolunca menzilde hedefe otomatik saldırı. | 10 | Çok kolay | **Var** | `weapons/weapon_base.gd` — `_process` içinde timer → `attack()`. |
| 2 | Tek çubuk kontrol | Sadece hareket. | Tek analog / WASD yeterli. | Sürekli ateş + yön tuşlarıyla gezinme. | 10 | Çok kolay | **Kısmi** | Solo: `player.gd` WASD/ok. **Local co-op:** ikinci giriş haritası gerekir — tek çubuk yalnızca solo için tam. |
| 3 | Anında restart | Ölünce hemen yeni run. | Tek tuşla menü labirenti olmadan. | Ölüm ekranında büyük “tekrar dene”. | 10 | Kolay | **Var** | `ui/game_over.gd` — `🔄 Tekrar Oyna`, `ObjectPool.reset_all()`, sahne `character_select`. |
| 4 | Görsel karmaşa | Mermi saydamlığı. | Yoğunlukta kendi mermilerini %50 saydam. | Ayarlarda “oyuncu efektleri opaklığı” slider. | 9 | Kolay | **Yok** | `SaveManager.settings` + `settings.gd` + sprite/modulate (bullet, shard, vb.) henüz yok. |
| 5 | Yüksek kontrast düşman | Outline ile seçilebilirlik. | Karmaşık arka planda düşman net. | Outline shader / hat. | 9 | Kolay | **Yok** | `enemy_base.gd` → `_setup_visuals()` uygun; shader atanmadı. |
| 6 | Düşük donanım | Zayıf PC’de oynanabilirlik. | Havuzlama, instancing, 60 FPS hedefi. | Object pooling, hafif render. | 9 | Orta | **Kısmi** | `ObjectPool` mermi/orb vb. Tam performans denetimi / instancing raporu yok. |
| 7 | Manyetik toplama | XP’nin çekilmesi. | Üstüne basmadan menzilden çekme. | Area + çekim hareketi. | 9 | Kolay | **Var** | `xp_orb.gd`, `gold_orb.gd` + `player.get_magnet_bonus()`; item magnet. |
| 8 | Kısa oyun döngüsü | 10–15 dk run. | “Bir el atıp çıkma” süresi. | Dalga + max süre kısıtı. | 8 | Orta | **Kısmi** | Hedef **~30 dk** hayatta kalma / Reaper (`wave_manager` 1800s). Kısa run için arena/ayrı mod gerekir. |
| 9 | Ekran sarsıntısı kapatma | Rahatsızlık önleme. | Screen shake opsiyonel. | Global `if shake_enabled`. | 8 | Çok kolay | **Var** | `settings["screen_shake"]`, `player.gd` / `EventBus` tetikleri. |
| 10 | Hasar sayılarını gizleme | Netlik / performans. | Damage numbers kapatılabilir. | Ayar tick’i. | 8 | Kolay | **Var** | `damage_numbers` string enum; `settings.gd` + `enemy_base` / `player`. |
| 11 | Öğretici yokluğu | Sezgisel öğrenme. | Uzun yazı yerine ilk saniyelerde his. | İlk düşman “soft” tanıtım. | 8 | Orta | **Kısmi** | Ayrı tutorial sahnesi yok; dalga doğrudan başlıyor. Bilinçli “güvenli ilk 10 sn” tasarımı yok. |
| 12 | Otomatik duraklatma | Odak kaybında pause. | Alt+Tab / mobil bildirim. | `Application Focus` → zaman durdur. | 7 | Çok kolay | **Yok** | `NOTIFICATION_APPLICATION_FOCUS_OUT` ile pause eklenmedi. |
| 13 | Renk körlüğü paleti | Tehlike renkleri alternatif. | Kırmızı alanlar için palet seçeneği. | Global tema değişkeni. | 7 | Kolay | **Yok** | Tema/palet sistemi yok. |
| 14 | Büyük net ikonlar | Level-up’ta ikon ağırlığı. | Uzun yazı yerine evrensel ikonlar. | Kılıç/kalp ikonları. | 7 | Orta | **Yok** | `upgrade_ui` ağırlıklı metin; ikon asset + UI yok. |
| 15 | Görsel ses uyarıları | Patlamadan önce blink. | Sadece ses değil görsel uyarı. | Tween blink. | 7 | Kolay | **Kısmi** | `exploder.gd` anında patlama + parçacık; `flash()` boş — **ön uyarı blink yok**. |
| 16 | Metin boyutu | Okunabilirlik. | Açıklama fontu büyütme. | Dinamik font scale. | 6 | Orta | **Yok** | Global font ölçeği yok. |
| 17 | Pencere / tam ekran | Hızlı ekran modu. | F11 / Alt+Enter benzeri. | Motor kısayolu. | 6 | Çok kolay | **Kısmi** | `settings.gd` ile tam ekran + çözünürlük var; **global F11 ataması** `project.godot` input’ta doğrulanmalı (isteğe bağlı). |
| 18 | Fare veya klavye | Hibrit girdi. | Fare yönü veya WASD. | Input birleştirme. | 6 | Kolay | **Yok** | `player.gd` hareket klavye/joypad; **fare pozisyonuna göre hareket yok**. |
| 19 | Gereksiz lore gizleme | Hikaye dayatmama. | Oyna → hızlı arena. | Lore ayrı sekme. | 5 | Kolay | **Kısmi** | Uzun lore ekranı yok; `main_menu` kısa tagline. Ayrı “hikaye sekmesi” yok — “gizleme” daha çok “yokluğu”. |
| 20 | Çevrimdışı çalışma | Sunucusuz tam oyun. | Lokal kayıt. | Local save. | 5 | Kolay | **Var** | `user://save.cfg`; liderlik tablosu yok. |

---

## Tablo 2 — Bağlılık / dopamin döngüsü (20 madde)

| # | Madde | Kısa açıklama | Detaylı açıklama (özet) | Oyuna uyarlama (özet) | Önem (1–10) | Geliştirilebilirlik | **Durum** | **Repo kontrolü** |
|---|--------|---------------|---------------------------|-------------------------|-------------|---------------------|----------|-------------------|
| 1 | Kalıcı geliştirmeler | Kaybedince de güçlenme. | Altın → kalıcı stat / ağaç. | Meta mağaza / skill tree. | 10 | Orta | **Var** | `SaveManager.meta_upgrades`, `ui/meta_upgrade.gd`. |
| 2 | Power fantasy | Zayıf başlayıp güçlenme. | Geç aşama ekran dolusu güç. | Üstel / agresif scaling. | 10 | Orta | **Var** | Silah level + evrim + meta; tam üstel denge testi ayrı konu. |
| 3 | Slot makinesi (level-up) | RNG kart beklentisi. | Duraklama + janjanlı seçenekler. | Ses + parlama + rastgele havuz. | 10 | Kolay | **Var** | `upgrade_ui.gd`, `weighted_pick`, level-up flash `player.gd`. |
| 4 | Silah evrimleri | Gizli kombinasyonlar. | İki max içerik → yeni silah. | ID eşleşmesi → evrim. | 10 | Zor | **Var** | `weapon_evolution.gd`, `player.evolve_weapon()`. |
| 5 | Hızlı erken level | İlk 60 sn dopamin. | İlk 5 level çok ucuz XP. | `_calc_xp_for_level` ayarı. | 9 | Çok kolay | **Kısmi** | Eğri tek formül; **ilk seviyeler özellikle hızlandırılmadı** (yol haritası işi). |
| 6 | Kilidi açılır karakter | Yeni oynanış. | Altın / başarı ile yeni karakter. | Seçim ekranı + pasifler. | 9 | Orta | **Var** | `character_data.gd`, `save_manager` unlock/purchase, sahneler. |
| 7 | Görsel juiciness | Ölümde patlama / his. | Hit-stop, parçacık, orb. | Death VFX. | 9 | Kolay–Orta | **Var** | `hit_stop`, damage numbers, orb drop, `show_vfx` dalları. |
| 8 | Tatmin edici ses (XP) | Pitch ile kombo hissi. | Ardışık toplamada pitch artışı. | `pitch_scale` dinamik. | 9 | Kolay | **Kısmi** | `audio_manager.gd` `play_xp()` — **pentatonik sıra** var; **streak bazlı sürekli yükselen pitch** yok. |
| 9 | Sandık heyecanı | Boss sandığı ritüeli. | Zaman durdurma + anim. | `chest` sekansı. | 8 | Orta | **Kısmi** | `effects/chest.gd` anında ödül; **özel açılış animasyonu yok**. |
| 10 | Beklenmedik boss | Rutin kırma. | Müzik + elit spawn. | Wave manager event. | 8 | Orta | **Var** | `wave_manager.gd` `mini_boss_times`; boss spawn olayları. |
| 11 | Koleksiyon / bestiary | %100 doldurma. | Keşfedilenler grid’i. | Menü + ID listesi. | 8 | Kolay | **Yok** | Wiki / koleksiyon menüsü yok. |
| 12 | Sayılar büyür | Oyun sonu dev istatistik. | Kill / hasar sayaçları. | Oyun sonu ekranı. | 7 | Kolay | **Var** | `game_over.gd` — süre, level, kill, KPM, altın. |
| 13 | Zorluk kademeleri | Ascension / Heat. | Run başı çarpanlar (Danger 0–5). | Global multiplier. | 7 | Kolay | **Kısmi** | `curse_level` meta; **run başı 0–5 seçim ekranı yok**. |
| 14 | Risk / ödül | Lanetli seçenekler. | Hasar ↑ can ↓ gibi. | Negatif + pozitif stat. | 7 | Orta | **Var** | `shrine_of_risk.gd` (risk / devil), shrine XP çarpanı `player.gain_xp`. |
| 15 | Çevre değişimi | Süreyle artan gerilim. | 5. dk gündüz → 10. dk kızıl. | `CanvasModulate` tween. | 7 | Kolay | **Yok** | Zamanla global renk/müzik tempo değişimi yok. |
| 16 | Gizli kilitler | Başarım → içerik. | Özel koşul → karakter/silah. | Achievement manager. | 6 | Orta | **Var** | `AchievementManager`; Omega kodu `main_menu`; unlock koşulları `character_data`. |
| 17 | Kombo / katliam | Hızlı kill geri bildirimi. | “Rampage” UI. | 2 sn timer sayaç. | 6 | Kolay | **Var** | `player.gd` `recent_kill_times`, “COMBO” floating text. |
| 18 | Farklı harita geometrileri | Labirent / engel. | Farklı tilemap sahneler. | Çoklu arena. | 6 | Orta–Zor | **Kısmi** | `map_select` çoğunlukla tek aktif harita; arena kilitli placeholder. |
| 19 | Kozmetik ödüller | Şapka / mermi rengi. | Başarım → görsel varyant. | Texture varyantı. | 5 | Kolay | **Yok** | Kozmetik unlock yok. |
| 20 | Gerçekçi son / hedef | Sonsuz değil net final. | 20. dk son boss vb. | Timer + boss fazı. | 5 | Zor | **Kısmi** | **30. dk** Reaper / galibiyet eşiği (`1800` s); **20. dk tek fazlı final boss** yok — tasarım farklı. |

---

## Özet sayım (hızlı bakış)

| Kategori | Var | Kısmi | Yok |
|----------|-----|-------|-----|
| Erişilebilirlik (20) | 6 | 7 | 7 |
| Bağlılık (20) | 11 | 6 | 3 |

*(Kısmi, hem “yarım” hem “hedef metinle tam örtüşmüyor” anlamında kullanıldı.)*

---

## Bu matrisi ne zaman güncelle?

Kod veya tasarım değişince ilgili satırın **Durum** ve **Repo kontrolü** sütunlarını güncelle; büyük paket sonunda `YOL_HARITASI.md` yapılan iş günlüğüne bir satır ekle.
