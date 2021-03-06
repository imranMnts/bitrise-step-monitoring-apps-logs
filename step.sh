#!/bin/bash
set -ex

if [[ ${log_count} != "" ]]; then
    LIMIT="$log_count"
else
    LIMIT="0"
fi

if [[ ${check_android} == "yes" ]]; then
    if [ ! -d "apk_decompiled" ]; then
        echo "ERROR: Cannot find any decompiled apk"
        exit 1
    fi

    ALL_LOGS=$(grep -ri "Landroid/util/Log;->i(\|Landroid/util/Log;->v(\|Landroid/util/Log;->w(\|Landroid/util/Log;->d(\|Landroid/util/Log;->e(" apk_decompiled/.)

    if [[ ${filter_path} != "" ]]; then
        echo "Filtered path 2: $filter_path"

        LOGS=$(echo "$ALL_LOGS" | grep -v $filter_path || true)
        COUNT_ANDROID_LOGS=$(echo "$ALL_LOGS" | grep -v $filter_path | wc -l)
    else
        LOGS="$ALL_LOGS"
        COUNT_ANDROID_LOGS=$(echo "$ALL_LOGS" | wc -l)
    fi
fi

echo "---- REPORT ----"

if [ ! -f "quality_report.txt" ]; then
    printf "QUALITY REPORT\n\n\n" > quality_report.txt
fi

printf ">>>>>>>>>>  APP LOGS  <<<<<<<<<<\n" >> quality_report.txt

if [[ ${COUNT_ANDROID_LOGS} == "" || ${COUNT_ANDROID_LOGS} -eq "0" ]]; then
    printf "0 log in your native Android code \n" >> quality_report.txt
else
    if [[ ${COUNT_ANDROID_LOGS} != "" && ${COUNT_ANDROID_LOGS} -gt "0" ]]; then
        printf "You have : $COUNT_ANDROID_LOGS logs in your Android code \n" >> quality_report.txt
        printf "Reported logs: $LOGS\n" >> quality_report.txt
    fi
fi

printf "\n\n" >> quality_report.txt

sed 's/apk_decompiled/\rapk_decompiled/g' quality_report.txt > /Users/vagrant/deploy/quality_report.txt
cp quality_report.txt /Users/vagrant/deploy/quality_report.txt || true

if [[ ${COUNT_ANDROID_LOGS} != "" && ${COUNT_ANDROID_LOGS} -gt $LIMIT ]]; then
    echo "Generate an error due to logs in your native codes"
    exit 1
fi
exit 0