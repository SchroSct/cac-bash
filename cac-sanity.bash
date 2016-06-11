########################################
## Basic sanity checks before running ##
########################################


## Do we know about our API

if [ ! -f cac-api-config.bash ]; then
    echo "ERROR: No cac-api-config.bash file."
    exit 1
fi


## Do we have the functions we need

if [ ! -f cac-functions.bash ]; then
    echo "ERROR: No cac-functions.bash file."
    exit 1
fi

