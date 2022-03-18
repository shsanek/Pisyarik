TELEGRAM_BOT_TOKEN=$1
TELEGRAM_BOT_CHAT=$2

export ARRLE_STOP="STOP"
sudo kill -9 `sudo lsof -t -i:8443`
sudo kill -9 `sudo lsof -t -i:8080`
sleep 15
export ARRLE_STOP="RUN"
tryes=5

./run_proxy.bash &

[[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"

while [ $STATE != "STOP" ] && [ "$tryes" -gt 0 ]; do
    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"-543384352\", \"text\": \"Собираю и запускаю серв... осталось попыток ${tryes}\"}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
    tryes=$((tryes-1))

    fileLog="log/$(date +"%Y_%m_%d_%I_%M_%p").log"

    sleep 5

    ~/swift-5.6-RELEASE-ubuntu18.04/usr/bin/swift run server 2>&1 | tee $fileLog

    sudo kill -9 `sudo lsof -t -i:8080`

    [[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"

    if [ $STATE != "STOP" ]; then
        curl -X POST \
            -H 'Content-Type: application/json' \
            -d "{\"chat_id\": \"${TELEGRAM_BOT_CHAT}\", \"text\": \"Чет не так сервер наебнулся\"}" \
            https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
        curl -F document=@"$fileLog" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument?chat_id=$TELEGRAM_BOT_CHAT
    fi
done

if [ $STATE != "STOP" ]; then

    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"-543384352\", \"text\": \"Попытки кончились иди перезагружай вручную\"}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage

else

    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"-543384352\", \"text\": \"Ручное завершение работы сервера\"}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage

fi
