# APUFirmware
PC Engines APU firmware auto downloader and updater

## Info

apufirmware v1.00 2022 (c) MonkeyCat (code.monkeycat.nl)

## See also

[APUCtl]() controls your hardware wifi on/off switch and your simcard slot from the command line.

## Usage

```
usage: apufirmware command

 info           show firmware information
 update         if new firmware is available, update and reboot
```

## Practical

When you run `apufirmware info`, it shows the current firmware info. You are also notified when a new update is available. If available, it is immediately downloaded and the rom verified.

When you run *apufirmware update* it will do the same as running `apufirmware info` with the addition that it also installs the newest update if available and preforms a cold boot.

## Typical output

```
model        apu4
serial       1279999
flash        Winbond W25Q64.V (8192Kb)
firmware     v4.16.0.2
update       v4.17.0.1 (https://3mdeb.com/open-source-firmware/pcengines/apu4/apu4_v4.17.0.1.rom)
updating     v4.17.0.1.rom
rebooting...
```

## Log

The log file containing the flashrom output is located in `/var/log/apufirmware.log`
 
## Errors

It return a non zero error code when failed, see the source what's what.

## Notes

Not erasing the bios settings when flashing works from versions *v4.14.0.1* onwards.

## Sources

 * [cold reset](https://pcengines.github.io/apu2-documentation/cold_reset/)
 * [firmware flashing](https://pcengines.github.io/apu2-documentation/firmware_flashing/)
