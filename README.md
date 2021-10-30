# Че тут

короче сейчас есть 9 методов

их код можно посмотреть в `Sources/App/Handlers`


## Входные данные

Все данные передаются в теле запроса в следующем формате

``` json
{
    "time": UInt, // текущие время не должно сильно отличаться от серверного
    "authorisation": {
        "token": String
        "secretKey": String // Берем хэш который собрали в login и делаем так SHA512(hash+time)
    }?
    "parameters": {
        //тут наш обьект (даже если парметров к запросу нет сюда надо все равно отправитьь пустой обьект) (дальше буду описывать только это поле Input)
    }
}

```

## Ответы

Все ответы приходят в формате

``` json
{
    "state": "ok" || "error"
    "content": {
        //тут наш контент если ok (дальше буду описывать только это поле Output)
    },
    "errors": [//если пошло по пизде
        {
            "name": String,
            "description": String,
            "info": String?
        }
    ]
}

```

### Еще немного общих типо

IdentifierType = UInt

User {
    name: String
    userId: IdentifierType
    isSelf: Bool // true - если вы этот пользователь
}

Message {
    user: User
    date: UInt
    body: String
    type: String
    messageId: IdentifierType
    chatId: IdentifierType
}

# Методы

можно post или get

## user

### user/login

Логинет пользователя возращает авторизационный токен

``` json
    Input {
        name: String,
        securityHash: String // SHA512(name+password),
        userPublicKey: String // Public part SymmetricKey user for secretKey
    }
```

``` json
    Output {
        token: String
        serverPublicKey: String // Public part SymmetricKey server for secretKey
        userId: Int
    }
```

###### example:
req:

``` json
{ 
    "parameters": {
        "name": "alex10"
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "token": "202C394B-D55E-421B-8172-B28DEB98EC24",
        "userId": 4
    }
}
```

### user/registration

Регистрирует пользователя, сразу логинет пользователя

``` json
    Input {
        name: String,
        securityHash: String // SHA512(name+password),
        userPublicKey: String // Public part SymmetricKey user for secretKey
    }
```

``` json
    Output {
        token: String
        serverPublicKey: String // Public part SymmetricKey server for secretKey
        userId: Int
    }
```
###### example:
req:

``` json
{ 
    "parameters": {
        "name": "alex10"
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {}
}
```


### user/search

поиск пользователя по имени

``` json
    Input {
        name: String
    }
```

``` json
    Output {
        users: [User]
    }
```
###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": {
        "name": "alex"
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "users": [
            {
                "name": "alex",
                "userId": 1,
                "isSelf": true
            },
            {
                "name": "alex2",
                "userId": 2,
                "isSelf": false
            },
            {
                "name": "alex3",
                "userId": 3,
                "isSelf": false
            },
            {
                "name": "alex4",
                "userId": 4,
                "isSelf": false
            },
            {
                "name": "alex6",
                "userId": 5,
                "isSelf": false
            },
            {
                "name": "alex8",
                "userId": 6,
                "isSelf": false
            }
        ]
    }
}
```

## chat

### chat/make

Создаем чат

``` json
    Input {
        name: String
    }
```

``` json
    Output {
        "chatId": IdentifierType
    }
```
###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": {
        "name": "Alex-Nikita3"
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "chatId": 5
    }
}
```

### chat/make_personal

Создаем чат c пользователем

``` json
    Input {
        userId: IdentifierType
    }
```

``` json
    Output {
        "chatId": IdentifierType
        "user": User
    }
```
###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": {
        "userId": 3
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "chatId": 5,
        "user": {
            "name": "alex10",
            "userId": 1,
            "isSelf": false
        }
    }
}
```

### chat/add_user

Добавить пользователя в чат

``` json
    Input {
        chatId: IdentifierType
        userId: IdentifierType
    }
```

``` json
    Output { }
```
###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": {
        "chatId": 3,
        "userId": 4
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {}
}
```

### chat/get_all_my

Список чатов в которые я добавлен

``` json
    Input { }
```

``` json
    Output {
        chats: [{
            message: Message?, //последние сообщение в чате
            name: String,
            chatId: IdentifierType,
            isPersonal: Bool // пометка о том что чат персональный ( в такие чаты нельзя добавить пользователей и их имя надо получать из списка пользователей чата),
            notReadCount: Int?
            lastMessageId: Int?
        }]
    }
```
###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": { }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "chats": [
            {
                "name": "Alex-Nikita3",
                "chatId": 1,
                "isPersonal": false,
                "notReadCount": 0,
                "lastMessageId": 1,
                "message": {
                    "user": {
                        "name": "alex10",
                        "userId": 1,
                        "isSelf": true
                    },
                    "content": "Start chat",
                    "messageId": 2,
                    "chatId": 1,
                    "type": "SYSTEM_TEXT",
                    "date": 657101002,
                    "notReadCount": 0,
                    "lastMessageId": 3
                }
            },
            {
                "name": "Alex-Nikit3",
                "chatId": 2,
                "isPersonal": false,
                "notReadCount": 0,
                "lastMessageId": 3,
                "message": {
                    "user": {
                        "name": "alex10",
                        "userId": 1,
                        "isSelf": true
                    },
                    "content": "Start chat",
                    "messageId": 3,
                    "chatId": 2,
                    "type": "SYSTEM_TEXT",
                    "date": 657101132
                }
            }
        ]
    }
}
```

### chat/get_users

Список пользователей в чате

``` json
    Input {
        chatId: IdentifierType
    }
```

``` json
    Output {
        users: [User]
    }
```

###### example:
req:

``` json
{ 
    "token":"94091781-F29B-4301-80B0-F0CF6BA103E7",
    "parameters": {
        "chatId": 3
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "users": [
            {
                "name": "alex8",
                "userId": 6,
                "isSelf": true
            },
            {
                "name": "alex2",
                "userId": 2,
                "isSelf": false
            }
        ]
    }
}
```

## message

### message/send

отправить сообщение в чат

``` json
    Input {
        type: String // произвольный типо обрабатывается на клиентах (можно писать че захотите до 15 символов)
        content: String // сам контент
        chatId: IdentifierType //в какой чат
    }
```

``` json
    Output {
        messageId: IdentifierType
    }
```

###### example:
req:

``` json
{ 
    "token":"94091781-F29B-430",
    "parameters": {
        "chatId": 3,
        "type": "text",
        "content": "Hello"
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "messageId": 7
    }
}
```

### message/set_read

Помечает сообщение прочитаным (предыдущие сообщения также будут считаться прочитанами)

``` json
    Input {
        messageId: IdentifierType
        chatId: IdentifierType
    }
```

``` json
    Output {
        count: Int // сколько осталось не прочитаных сообщений
    }
```

###### example:
req:

``` json
{ 
    "token":"94091781-F29B-430",
    "parameters": {
        "messageId": 3,
        "chatId": 2
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "count": 0
    }
}
```

### message/get_from_chat

Выгружает сообщения из чата начиная с последних

``` json
    Input {
        chatId: IdentifierType // из какого чата
        limit: Int // сколько грузить max(100)
        lastMessageId: IdentifierType? // id последнего загруженного сообщения ( какое сообщение послдение загрузили в прошлый раз),
        reverse: Bool? // инвертирует сортировку начинает грузить с первого сообщения (или то сообщение которое после lastMessageId)
    }
```

``` json
   Output: Codable {
        messages: [Message]
    }
```

###### example:
req:

``` json
{ 
    "token":"94091781-F29B-430",
    "parameters": {
        "chatId": 3,
        "limit": 10,
        "lastMessageId": 2
    }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "messages": [
            {
                "user": {
                    "name": "alex8",
                    "userId": 6,
                    "isSelf": false
                },
                "content": "Hello",
                "chatId": 3,
                "type": "text",
                "messageId": 1,
                "date": 657047168
            }
        ]
    }
}
```

## Update

### update/get

Возращает список обновлений (нужен большой тайм аут > 30)


``` json
    Input {}
```


``` json
Output {
    notifications: [{
        type: string // типо нотификации
        content: Any // контент этого типа нотификаций
    }]
}
```

##### типы нотификаций

```
{
    type: newMessage,
    content: Message
}
```

```
{
    type: addedInNewChat,
    content: {
        name: String,
        chatId: IdentifierType,
        isPersonal: Bool
    }
}
```

```
{
    type: newPersonalChat,
    content: {
        chatId: IdentifierType,
        user: User    
    }
}
```

###### example:
req:

``` json
{ 
    "token":"94091781-F29B-430",
    "parameters": { }
}
```
res:

``` json
{
    "state": "ok",
    "content": {
        "notification": []
    }
}
```
