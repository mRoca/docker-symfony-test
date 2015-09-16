#!/usr/bin/env bash

CACHE_DIR=/tmp/

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --cache-dir)
            CACHE_DIR=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            exit 1
            ;;
    esac
    shift
done

if [ -f $CACHE_DIR/.php_cs.cache ]; then
    cp $CACHE_DIR/.php_cs.cache .php_cs.cache
else
    echo "No cs fixer cache"
fi

if PHPCS_OUPUT=$(php-cs-fixer fix --no-interaction --dry-run --diff -vvv); then
    PHPCS_EXIT_CODE=0
else
    PHPCS_EXIT_CODE=1
fi

if [ -f .php_cs.cache ]; then
    cp .php_cs.cache $CACHE_DIR/.php_cs.cache;
else
    echo "Cannot find the .php_cs.cache file"
fi

if [[ $PHPCS_EXIT_CODE -ne 0 ]]; then
    echo "FAIL> The coding style is invalid. Please fix above issues." && false
    echo "$PHPCS_OUPUT"
else
    echo "SUCCESS> The coding style is valid."
fi

exit $PHPCS_EXIT_CODE
