# APUFirmware
PC Engines APU firmware auto downloader and updater

## Info

apufirmware v1.00 2022 (c) MonkeyCat (code.monkeycat.nl)

## See also

[apuctl]() control your hardware wifi on/off and your simcard slot from the command line

## Usage

usage: apufirmware command

 info           show firmware information
 update         if new firmware is available, update and reboot

## Practical

When you run apufirmware info it shows the current firmware info and if there is an update available which is immediately downloaded and its SHA256 checked
When you run apufirmware update it will do the same as running info with the addition that is also installs the newest update if available and preforms a cold boot
 
## Notes

The persistent runtime configuration works only when migrating from versions v4.14.0.1

## Sources

[source](https://pcengines.github.io/apu2-documentation/cold_reset/)
[source](https://pcengines.github.io/apu2-documentation/firmware_flashing/)
