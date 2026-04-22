class_name GameplayConstants
extends RefCounted

## Piksel: co-op’ta tüm oyuncuların ağırlık merkezinden her bir oyuncuya izin verilen üst mesafe (`main/main.gd`),
## ve yıldırım silahının sahibi oyuncudan hedef düşmana kadar izin verilen üst mesafe (`weapon_lightning.gd`).
## Tek ayar noktası — iki davranış aynı “savaş ufku” tavanında kalsın diye.
const MAX_COMBAT_RADIUS_PX := 600.0

## Savrulan balta / kan baltası: hedef seçmeden önce oyuncu–düşman üst sınırı (mermi menziline yakın).
const THROW_WEAPON_ENGAGE_RANGE_PX := 560.0

## Buz topu `speed` × `lifetime` (280 × 2.5) ile uyumlu üst yakalama menzili.
const ICE_BALL_ENGAGE_RANGE_PX := 700.0
