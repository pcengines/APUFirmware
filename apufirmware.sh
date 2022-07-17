#!/bin/bash
echo "apufirmware v1.00 2022 (c) MonkeyCat (code.monkeycat.nl)"
echo

if [[ "$#" != "0" ]]; then

    if [ "$EUID" -ne 0 ]; then
        echo "not root"
        exit 1
    fi

    model=$(dmidecode -t baseboard | grep Product | cut -d' ' -f 3)
    serial=$(dmidecode -t baseboard | grep "Serial" | cut -d' ' -f 3)

    if [[ $(echo $model | sed 's/.$//') != "apu" ]]; then
        echo "not an apu"
        exit 2
    fi

    url_crawl() {
        base=$(wget -q -O- $1 | tr ' ' '\n' | sed -n 's/.*href=\([^( |>)]*\).*/\1/p' | sed 's/"//g' | sed 's/'\''//g' | sort -u)
        for var in "${@:2}"; do
            if [[ "$var" == "sort" ]]; then
                base=$(echo "$base" | sort -V | tail -1)
            else
                base=$(echo "$base" | grep "$var")
            fi
        done
        echo "$base"
    }

    romlink=$(url_crawl "https://pcengines.github.io" "\.rom" "$model" "sort")
    shalink=$(echo "$romlink" | sed 's/.rom/.SHA256/')
    romfile=$(echo "$romlink" | sed 's/.*\///')
    shafile=$(echo "$shalink" | sed 's/.*\///')
    latest=$(echo "$romfile" | sed 's/.*v//' | sed 's/.rom//' | sed 's/^/v/')
    current=$(dmidecode -s bios-version)
    flashinfo=$(2>/dev/null flashrom -p internal --flash-name | tail -1)
    flashsize=$(2>/dev/null flashrom -p internal --flash-size | tail -1)
    flashvendor=$(echo $flashinfo | cut -d' ' -f 1 | cut -d'=' -f 2 | sed 's/"//g')
    flashchip=$(echo $flashinfo | cut -d' ' -f 2 | cut -d'=' -f 2 | sed 's/"//g')

    echo "model        $model"
    echo "serial       $serial"
    echo "flash        $flashvendor $flashchip ($(($flashsize / 1024))Kb)"
    echo "firmware     $current"

    if [ ! -z "${romlink}" ]; then
        if [[ $(printf '$latest\n$current' | sort | tail -1) != "$current" ]]; then
            echo "update       $latest ($romlink)"
            if [[ ! -f "$romfile" ]]; then
                wget -q "$romlink"
            fi
            if [[ ! -f "$shafile" ]]; then
                wget -q "$shalink"
            fi


            if [[ "$(cat $shafile | cut -d' ' -f1)" != "$(sha256sum $romfile | cut -d' ' -f1)" ]]; then
                echo "download failed $romfile"
                rm "$romfile"
                rm "$shafile"
                exit 3
            fi
        fi
    fi

    if [[ "$1" == "update" ]]; then
        if [ ! -z "${romlink}" ]; then
            if [[ $(printf '$latest\n$current' | sort | tail -1) != "$current" ]]; then
                if [[ -f "$romfile" ]]; then
                    if [[ "$(cat $shafile | cut -d' ' -f1)" == "$(sha256sum $romfile | cut -d' ' -f1)" ]]; then
                        echo "updating     $romfile"
                        flashrom -p internal -w "$romfile" --fmap -i COREBOOT >> /var/log/apufirmware.log 2>&1
                        if [ $? -ne 0 ]; then
                            echo "failed... see /var/log/apufirmware.log"
                            cat /var/log/apufirmware.log
                            exit 4
                        fi
                        echo "rebooting..."
                        for i in s u; do echo $i | sudo tee /proc/sysrq-trigger > /dev/null 2>&1; sleep 15; done
                        echo -ne "\xe" | dd of=/dev/port bs=1 count=1 seek=$((0xcf9))
                    fi
                fi
           fi
       fi
    fi
else
    echo "usage: apufirmware command"
    echo
    echo " info           show firmware information"
    echo " update         if new firmware is available, update and reboot"
    echo
fi
