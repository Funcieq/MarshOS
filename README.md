# MarshOS

Prosty hobbystyczny OS x86_64 w C, uruchamiany przez Limine.
Minimalny kernel sprawdza rewizję protokołu Limine i zatrzymuje procesor.

## Szybki start (Linux)

Na Debianie/Ubuntu zainstaluj narzędzia:

```sh
sudo apt install build-essential curl ca-certificates xorriso qemu-system-x86 ovmf
```

Po zwykłym `git clone <URL-repo>` wejdź do katalogu projektu:

```sh
cd MarshOS
make run
```

Nie trzeba klonować submodułów ani ręcznie instalować Limine. Pierwszy build
pobiera oficjalne binaria **Limine v12.10.0** i nagłówek protokołu do `.deps/`,
sprawdza SHA-256 i tworzy `build/marshos.iso`. Kolejne buildy działają offline.
Kernel nie wyświetla jeszcze tekstu ani grafiki.
Zamknięcie okna QEMU kończy emulator.

## Polecenia

```sh
make               # ISO obsługujące BIOS i UEFI x86_64
make kernel        # sam kernel ELF
make deps          # samo pobranie zależności
make run           # QEMU, BIOS
make run-uefi OVMF=/usr/share/OVMF/OVMF_CODE_4M.fd
make clean         # usuń build, zachowaj pobrane zależności
make distclean     # usuń również .deps (następny build wymaga internetu)
```

Ścieżka OVMF zależy od dystrybucji. Użyj firmware bez wymogu Secure Boot.
Domyślne `cc` i `ld` muszą obsługiwać x86_64 ELF (np. GCC/binutils na Linux x86_64).
Cross-kompilacja: `make CC=x86_64-elf-gcc LD=x86_64-elf-ld`; narzędzie hosta
Limine nadal kompiluje się przez `HOST_CC=cc`.

Pliki C z `src/` są wykrywane automatycznie, a pliki obiektowe zachowują
strukturę katalogów w `build/`. Nagłówki mają śledzone zależności.
Możesz podać własne `CFLAGS`, `LDFLAGS` i `QEMUFLAGS`, np. `make CFLAGS="-O0 -g -Wall"`.
Po zmianie flag wykonaj `make clean` przed kolejnym buildem.

## VS Code / LSP

Otwórz główny katalog `MarshOS` jako folder projektu i wykonaj `make deps`,
aby nagłówek `limine.h` był dostępny lokalnie.
Konfiguracja `.vscode/c_cpp_properties.json` ustawia ścieżki dla rozszerzenia
Microsoft C/C++, a `compile_flags.txt` dla clangd.
Po dodaniu konfiguracji uruchom `Developer: Reload Window` z palety poleceń VS Code.
Przy zmianie wersji Limine w `deps/limine.mk` zaktualizuj również ścieżkę
w obu plikach konfiguracji edytora.

## Pliki

- `src/kernel/main.c` — minimalne wejście kernela i deklaracje protokołu Limine.
- `src/kernel/linker.ld` — układ ELF w górnej części przestrzeni adresowej.
- `limine.conf` — wpis startowy systemu.
- `deps/limine.mk` — przypięta wersja, commit nagłówka i sumy SHA-256.
- `scripts/fetch-limine.sh` — pobieranie i weryfikacja zależności.

Limine pochodzi z [oficjalnego wydania v12.10.0](https://github.com/Limine-Bootloader/Limine/releases/tag/v12.10.0).
Nagłówek pochodzi z [limine-protocol](https://github.com/Limine-Bootloader/Limine-protocol),
z commita zapisanego w `deps/limine.mk`. Aktualizując zależności, zmień też ich
sumy SHA-256, a potem wykonaj `make clean all`. Licencje zależności znajdują się
w pobranym pakiecie i repozytorium protokołu; licencja projektu jest w `LICENSE`.
