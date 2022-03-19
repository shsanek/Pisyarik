TELEGRAM_BOT_TOKEN=$1
TELEGRAM_BOT_CHAT=$2
BUILD_TYPE="debug"

sendMessage () {
    local text="$1"
    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"${TELEGRAM_BOT_CHAT}\", \"text\": \"${text}\"}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}

sendFile () {
    sendMessage "$1"
    curl -F document=@"$2" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument?chat_id=$TELEGRAM_BOT_CHAT
}

sendMessage "Начинаем сборку проэкта в ${BUILD_TYPE} режиме (в релизном занимает до 15 минут)."
fileLog="log/$(date +"%Y_%m_%d_%I_%M_%p").log"
if swift build -c $BUILD_TYPE --product server 2>&1 | tee $fileLog; then
    sendMessage "Cборка прошла успешно"
else
    sendFile "Во время сборки что то пошло не так исполнение не будет продолжено" $fileLog
    exit 1
fi

sendMessage "Копируем в исполняемую категорию. Останваливаем старый проект перезапускаем прокси, запускаем демона"

export ARRLE_STOP="STOP"
sudo kill -9 `sudo lsof -t -i:8443`
sudo kill -9 `sudo lsof -t -i:8080`
sleep 5
scp -r build .build
export ARRLE_STOP="RUN"
tryes=5
./run_proxy.bash &

[[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"

while [ "$STATE" != "STOP" ] && [ "$tryes" -gt 0 ]; do
    sendMessage "Цикл демона. Осталось попыток: ${tryes}\"}"

    tryes=$((tryes-1))

    fileLog="log/$(date +"%Y_%m_%d_%I_%M_%p").log"

    sleep 5

    ./build/$BUILD_TYPE/server 2>&1 | tee $fileLog

    sudo kill -9 `sudo lsof -t -i:8080`

    [[ -z "${ARRLE_STOP}" ]] && STATE='default' || STATE="${ARRLE_STOP}"

    if [ $STATE != "STOP" ]; then
        sendFile "Сервер упал" $fileLog
    fi
done

if [ $STATE != "STOP" ]; then
    sendMessage "Попытки закончились перезагрузите сервер в ручную"
else
    sendMessage "Ручная остановка сервера"
fi
