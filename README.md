# Че тут

короче сейчас есть 9 методов

их код можно посмотреть в `Sources/App/Handlers`


## Входные данные

Все данные передаются в теле запроса в следующем формате

``` json
{
    "token": String?,
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
    identifier: IdentifierType
}

# Методы

можно post или get

## user

### user/login

Логинет пользователя возращает авторизационный токен

``` json
    Input {
        name: String
    }
```

``` json
    Output {
        token: String
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
        "token": "202C394B-D55E-421B-8172-B28DEB98EC24"
    }
}
```

### user/registration

Регистрирует пользователя

``` json
    Input {
        name: String
    }
```

``` json
    Output {}
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
                "identifier": 1
            },
            {
                "name": "alex2",
                "identifier": 2
            },
            {
                "name": "alex3",
                "identifier": 3
            },
            {
                "name": "alex4",
                "identifier": 4
            },
            {
                "name": "alex6",
                "identifier": 5
            },
            {
                "name": "alex8",
                "identifier": 6
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
        chats: [ {
            name: String,
            identifier: IdentifierType
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
            "name": "Alex-Nikita2",
            "identifier": 3
        },
        {
            "name": "govnoa",
            "identifier": 4
        }
    ]
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
                "identifier": 6
            },
            {
                "name": "alex2",
                "identifier": 2
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

### message/get_from_chat

Выгружает сообщения из чата начиная с последних

``` json
    Input {
        chatId: IdentifierType // из какого чата
        limit: Int // сколько грузить max(100)
        lastMessageId: IdentifierType? // id последнего загруженного сообщения ( какое сообщение послдение загрузили в прошлый раз)
    }
```

``` json
   Output: Codable {
        messages: [{
            user: User
            date: UInt
            body: String
            type: String
            identifier: IdentifierType
            chatId: IdentifierType
        }]
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
                    "identifier": 6
                },
                "body": "Hello",
                "chatId": 3,
                "type": "text",
                "identifier": 1,
                "date": 657047168
            }
        ]
    }
}
```

