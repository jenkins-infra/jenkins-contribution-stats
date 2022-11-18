#!/usr/bin/env bash

set -e

year="2020"
month="FEB"

full_date="${month}-${year}"
case "$month" in
    JAN) echo "January"
        ;;
    FEB) echo "February"
        month_decimal="02"
        last_day=$(gdate -d "${year}/${month_decimal}/1 + 1 month - 1 day" "+%d")
        ;;
    MAR) echo "March"
        ;;
    APR) echo "April"
        ;;
    *) echo "Unsupported month: $month"
        exit 1
        ;;
esac

echo "${full_date}"
echo "month: ${month_decimal}"
echo "last day of month: ${last_day}"