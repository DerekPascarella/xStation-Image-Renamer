# xStation Image Renamer
A utility to rename CUE/BIN files to reflect folder name, as to customize game list as it appears in [xStation](https://github.com/x-station)'s menu.

The xStation uses the first data track of a disc image (minus its file extension) as that game's label in its menu. As a result, the only way to customize the way game names appear in the menu is to modify the filenames of the disc image itself. Doing so manually is tedious, as not only do the filesnames of the tracks themselves need to be renamed, but the corresponding CUE sheet must be modified to reflect said changes.

Pointing this utility as an xStation-formatted SD card will automatically perform all of the file renaming, as well as CUE modification. The only pre-requisite is reaming each game's folder to what which should be displayed in xStation's menu.

## Current Version
xStation Image Renamer is currently at version [1.0](https://github.com/DerekPascarella/xStation-Image-Renamer/raw/main/xstation_renamer.exe).

## Supported Features
Below is a specific list of the current features.

* Support for disc images in CUE/BIN format (e.g., [Redump](http://redump.org/)).
* Support for nested folders on target SD card.
* Support for disc images with more than one track (i.e., multiple BIN files).

## Example Usage
Generic usage:
```
xstation_renamer <PATH_TO_SD_CARD>
```

## Example Scenario
In this example, the directory structure of our SD card (E:\) appears as follows.

```
E:\
├── 00xstation
├── JAPAN
│   └── ...Iru! (Japan)
│       ├── ...Iru! (Japan) (Track 1).bin
│       ├── ...Iru! (Japan) (Track 2).bin
|       └── ...Iru! (Japan).cue
├── TRANSLATIONS
│   └── Harmful Park (English v1.1)
│       ├── Harmful Park (English v1.1).bin
│       └── Harmful Park (English v1.1).cue
└── USA
    └── Tomb Raider (USA) (Rev 6)
        ├── Tomb Raider (USA) (Rev 6) (Track 01).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 02).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 03).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 04).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 05).bin
         ---------- <REMOVED FOR BREVITY> ----------
        ├── Tomb Raider (USA) (Rev 6) (Track 55).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 56).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 57).bin
        └── Tomb Raider (USA) (Rev 6).cue
```

Before running this utility, we'll rename each game folder to how we'd like it to appear in the xStation menu. Note that we aren't renaming any CUE or BIN files, only folders.

```
E:\
├── 00xstation
├── JAPAN
│   └── ...Iru!
│       ├── ...Iru! (Japan) (Track 1).bin
│       ├── ...Iru! (Japan) (Track 2).bin
|       └── ...Iru! (Japan).cue
├── TRANSLATIONS
│   └── Harmful Park
│       ├── Harmful Park (English v1.1).bin
│       └── Harmful Park (English v1.1).cue
└── USA
    └── Tomb Raider
        ├── Tomb Raider (USA) (Rev 6) (Track 01).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 02).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 03).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 04).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 05).bin
         ---------- <REMOVED FOR BREVITY> ----------
        ├── Tomb Raider (USA) (Rev 6) (Track 55).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 56).bin
        ├── Tomb Raider (USA) (Rev 6) (Track 57).bin
        └── Tomb Raider (USA) (Rev 6).cue
```

Next, we'll execute `xstation_renamer.exe` at the terminal to begin processing the SD card.

```
PS C:\> .\xstation_renamer.exe E:\

xStation Image Renamer v1.0
Written by Derek Pascarella (ateam)

This program will process Redump-formatted CUE/BIN disc images
stored in separate folders within the following location:

> E:/

A total of 3 folder(s) containing files were found.

Proceed? (Y/N) y

> Processing xStation SD card...

> ...Iru!
  -Location: E:/JAPAN/...Iru!
  -Found CUE: Yes
  -CUE filename: ...Iru! (Japan).cue
  -Found BINs: Yes (2 total)
  -Renaming CUE: ...Iru!.cue
  -Renaming BINs: Done
  -Updating CUE: Done

> Tomb Raider
  -Location: E:/USA/Tomb Raider
  -Found CUE: Yes
  -CUE filename: Tomb Raider (USA) (Rev 6).cue
  -Found BINs: Yes (57 total)
  -Renaming CUE: Tomb Raider.cue
  -Renaming BINs: Done
  -Updating CUE: Done

> Harmful Park
  -Location: E:/TRANSLATIONS/Harmful Park
  -Found CUE: Yes
  -CUE filename: Harmful Park (English v1.1).cue
  -Found BINs: Yes (1 total)
  -Renaming CUE: Harmful Park.cue
  -Renaming BINs: Done
  -Updating CUE: Done

> Disc image renaming complete!

Disc images processed: 3
Ignored for no CUE:    0
Ignored for no BINs:   0
Processing time:       0.17 seconds

```

After conversion, the following folders appear within the `DREAMCAST` folder in the root of the SD card.

```
18 WHEELER - AMERICAN PRO TRUCKER
4 WHEEL THUNDER
4X4 EVOLUTION
ALICE DREAMS TOURNAMENT
ALIEN FRONT ONLINE
ALONE IN THE DARK - THE NEW NIGHTMARE
AQUA GT
```

Below, we see an example of a single-folder multi-disc game.

```
disc1_disc.gdi
disc1_track01.bin
disc1_track02.raw
disc1_track03.bin
disc1_track04.raw
disc1_track05.bin
disc2_disc.gdi
disc2_track01.bin
disc2_track02.raw
disc2_track03.bin
disc2_track04.raw
disc2_track05.bin
```

Furthermore, the GDI files themselves are modified to reflect the new filenames.

```
5
1 0 4 2352 disc1_track01.bin 0
2 756 0 2352 disc1_track02.raw 0
3 45000 4 2352 disc1_track03.bin 0
4 100806 0 2352 disc1_track04.raw 0
5 101407 4 2352 disc1_track05.bin 0
```

```
5
1 0 4 2352 disc2_track01.bin 0
2 756 0 2352 disc2_track02.raw 0
3 45000 4 2352 disc2_track03.bin 0
4 59804 0 2352 disc2_track04.raw 0
5 60405 4 2352 disc2_track05.bin 0
```
