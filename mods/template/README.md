# Tricky Mod for ModCore

This repository is a work in progress.

An example mod for Enigma Engine which implements parts of the popular "Full-Ass Tricky Mod" game mod. Please use this as a working example to create your own mods.

## Demo

Watch a demo here:

https://www.youtube.com/watch?v=1A5ChNEf5F4

## Features

This mod features the following:

* Custom title sequence and intro credits.
* Adds Tricky (Mask) as a usable Dad character.
* Adds Improbable Outset as a song to Free Play (currently uses the default stage).

This mod does not currently include:

* The Tricky (Unmasked) character.
* The Tricky (Hellclown) character.
* The Tricky (Expurgation) character.
* The song Madness.
* The song Hellclown.
* The song Expurgation.
* The custom stages (`nevada`, `nevadaSpook`, and `auditorHell`).
* A playable story week.
* Custom note types.
* Custom song behavior (such as obstructions or health drain).
* A custom title screen.
* A custom main menu.
* A main menu trophy for beating the story.
* Unlocking Expurgation only after beating the story on Hard.

## Notes

* `_polymod_meta.json` includes data used for the mod menu.
* `_polymod_icon.png` includes the icon used for the mod menu.
* All other assets use the proper file names and locations of the respective files in the `assets` folder, so that ModCore performs the replacement when the mod loads.
* New assets are simply placed in their proper locations where the game can locate them.
  * New characters are created by initializing a custom character metadata file, which includes necessary offsets and animation prefix names.
  * New songs are created simply by placing their music in the `songs` folder, their charts in the `data/songs` folder, and the song ID, week number, and character name for the icon to use in `_append/data/freeplaySongnames.txt`.

## Licensing

The Full Ass Tricky Mod is licensed under the [Creative Commons Attribution-NonCommercial-NoDerivs 4.0 Unported License](https://creativecommons.org/licenses/by-nc-nd/4.0/). It was created by [BanBuds](https://gamebanana.com/members/1785113) and others on GameBanana and was originally uploaded [to this page](https://gamebanana.com/mods/44334). 

This repository redistributes this mod in a different format, with additional data to allow it to be used with the Enigma Engine ModCore system. CC licenses grant permission to use the licensed material in any media or format regardless of the format in which it has been made available.

If you are the original licensor for some or all of the content available here, please contact me with sufficient proof of ownership and a request to take down the repository.

