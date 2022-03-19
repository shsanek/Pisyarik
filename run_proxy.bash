cd proxy

[[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"

while [ "$STATE" != "STOP" ]; do
    sleep 5

    node index.js

    sudo kill -9 `sudo lsof -t -i:8443`

    [[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"
done
