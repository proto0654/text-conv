# text-conv

Правка **уже выделенного** текста по хоткею в Hyprland/Wayland: смена раскладки
(латиница ⇄ кириллица) и инверсия регистра. Без автопереключения и без
фонового демона — только два биндинга и скрипт.

```
Ghbdtn, rfr ltkf?   →  Shift+Pause  →  Привет, как дела?
ПРИВЕТ мир          →  Alt+Pause    →  привет МИР
```

## Возможности

- **Смена раскладки** (`layout`): `en→ru` или `ru→en` — направление выбирается по
  преобладающим буквам, так что одна клавиша работает в обе стороны.
- **Инверсия регистра** (`case`): посимвольная, `Привет` → `пРИВЕТ`.
- Пунктуация остаётся пунктуацией: `Ghbdtn, rfr ltkf?` → `Привет, как дела?`,
  а не `Приветб как дела,`. Знак превращается в букву только внутри слова.
- Поддержка `ё`/`Ё`, shift-символов (`?`, `:`, `«»` и т.п. по позициям клавиш).
- Работает в GUI-приложениях и в терминалах (там используется `Ctrl+Shift+C/V`).
- Переключает системную раскладку на тот язык, в который сконвертирован текст:
  `en→ru` включает русскую, `ru→en` — английскую (`hyprctl switchxkblayout` по всем
  клавиатурам, у которых в `kb_layout` есть нужный язык).
- Буфер обмена восстанавливается через 1,5 с — то, что у вас было скопировано,
  не теряется.

## Требования

- Hyprland (используется `hyprctl`; на wlroots-композиторах без него не заработает).
- `python3`, `wtype`, `wl-clipboard` (`wl-copy`/`wl-paste`).
- Настроенная пара раскладок `us,ru`.

Arch/Omarchy:

```bash
sudo pacman -S --needed python wtype wl-clipboard
```

## Установка

```bash
git clone https://github.com/<you>/text-conv.git
cd text-conv
./install.sh                  # кладёт скрипт в ~/.local/bin
```

Затем добавьте биндинги в `~/.config/hypr/bindings.lua` (Omarchy/Hyprland Lua-конфиг):

```lua
o.bind("SHIFT + PAUSE", "Сменить раскладку выделенного", "/home/<you>/.local/bin/text-conv layout")
o.bind("SHIFT + BREAK", "Сменить раскладку выделенного", "/home/<you>/.local/bin/text-conv layout")
o.bind("ALT + PAUSE", "Инвертировать регистр выделенного", "/home/<you>/.local/bin/text-conv case")
o.bind("ALT + BREAK", "Инвертировать регистр выделенного", "/home/<you>/.local/bin/text-conv case")
```

Классический `hyprland.conf` (не Omarchy-обвязка, а обычный Hyprland — без Lua):

```ini
bind = SHIFT, Pause, exec, /home/<you>/.local/bin/text-conv layout
bind = SHIFT, Break, exec, /home/<you>/.local/bin/text-conv layout
bind = ALT,   Pause, exec, /home/<you>/.local/bin/text-conv case
bind = ALT,   Break, exec, /home/<you>/.local/bin/text-conv case
```

Почему дублируется `PAUSE` и `BREAK`: в XKB клавиша `<PAUS>` объявлена как
`[ Pause, Break ]` с `PC_CONTROL_LEVEL2`, то есть с зажатым Shift она отдаёт
keysym `Break`, и биндинг только на `PAUSE` не сработает.

После правки: `hyprctl reload && hyprctl configerrors`.

## Использование

1. Выделите текст мышью (или `Ctrl+A`, `Shift+стрелки`) — либо просто поставьте
   курсор после слова, тогда скрипт возьмёт слово слева.
2. `Shift+Pause` — сменить раскладку, `Alt+Pause` — инвертировать регистр.

## Как это работает

Скрипт без демона и без чтения клавиатуры:

1. Определяет активное окно (`hyprctl activewindow -j`) — терминал или нет.
2. Кладёт в буфер уникальную метку, посылает `Ctrl+C` (`Ctrl+Shift+C` в
   терминалах) и ждёт, пока в буфере появится выделенный текст. Метка на месте —
   значит, ничего не выделено.
3. Если копирование не удалось: читает PRIMARY-выделение (то, что отдаёт
   выделение мышью, — спасает в Electron/Chromium, где синтетический `Ctrl+C`
   игнорируется), затем пробует выделить слово слева от курсора.
4. Конвертирует, кладёт результат в буфер, посылает `Ctrl+V` / `Ctrl+Shift+V`,
   через 1,5 с возвращает прежний буфер.

## Ограничения

- **Текст страницы в браузере не редактируется** — вставка просто ничего не
  делает. Работает в полях ввода, textarea, `contenteditable`, редакторах,
  чатах и терминалах.
- В терминалах вставка терминальная: внутри `vim`/`htop` это обычный paste,
  а не замена выделения.
- Смена раскладки меняет символы, но не переключает саму раскладку системы
  (Punto переключает; здесь в этом нет нужды, потому что текст правится целиком).

## Отладка

```bash
TEXT_CONV_DEBUG=1 ~/.local/bin/text-conv layout   # подробный лог
tail -20 /tmp/text-conv.log
printf 'Ghbdtn' | ~/.local/bin/text-conv layout --stdin   # проверка конвертации без GUI
```

## Проверено

Omarchy (Hyprland, Wayland): Chromium (поля ввода), Electron-чаты, `foot`
(терминальная ветка), Omarchy shell. Скрипт зависит от `hyprctl` и
`wl-clipboard`, поэтому на GNOME/KDE заработает только после замены определения
активного окна.

## Лицензия

MIT.
