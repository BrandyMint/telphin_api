## telphin_api [![Build Status](https://secure.travis-ci.org/rootooz/telphin_api.png)](http://travis-ci.org/rootooz/telphin_api) [![Gem Version](https://badge.fury.io/rb/telphin_api.png)](http://badge.fury.io/rb/telphin_api) [![Dependency Status](https://gemnasium.com/7even/telphin_api.png)](https://gemnasium.com/7even/telphin_api) [![Code Climate](https://codeclimate.com/github/7even/telphin_api.png)](https://codeclimate.com/github/7even/telphin_api)

`telphin_api` &mdash; ruby-адаптер для Телфин. Он позволяет вызывать методы API, а также поддерживает получение токена для работы с API.

## Установка

``` ruby
# Gemfile
gem 'telphin_api'
```

или просто

``` sh
$ gem install telphin_api
```

## Использование

### Вызов методов

``` ruby
# создаем клиент
@tph = TelphinApi::Client.new
# и вызываем методы API
@tph.extensions.phone_call_events(:user_id => '@me', :extension_number => '00000*101', :method => :get)

# в ruby принято использовать snake_case в названиях методов,
# поэтому extensions.phoneCallEvents становится extensions.phone_call_events
@tph.extensions.phone_call_events

# большинство методов возвращает структуры Hashie::Mash
# и массивы из них
call_events.first.id        # => bMf0iCJneuA0YWawjUOjVTzAGn
call_events.first.url       # => https://site/api/telphin/call/out
call_events.first.method    # => 0
call_events.first.status    # => 1
call_events.first.type      # => 1

# если метод, возвращающий массив, вызывается с блоком,
# то блок будет выполнен для каждого элемента,
# и метод вернет обработанный массив
@tph.extensions.phone_call_events(:user_id => '@me', :extension_number => '00000*101', :method => :get) do |event|
  "#{event.id} '#{event.url}' #{event.method}"
end
# => ["bMf0iCJneuA0YWawjUOjVTzAGn 'https://site/api/telphin/call/out' 0"]
```

### Авторизация

Для авторизации необходимо задать параметры `app_key` (Ключ клиента), `app_secret` (Секрет клиента) и `site` (адрес вашего API сервера, полученного при заключении договора) в настройках `TelphinApi.configure`. Более подробно о конфигурировании `telphin_api` см. далее в соответствующем разделе.

`telphin_api` предоставляет метод `TelphinApi.authorize`, который делает запрос к Телфин, получает токен и создает клиент:

``` ruby
@tph = TelphinApi.authorize
# и теперь можно вызывать методы API на объекте @tph
@tph.token
```

Клиент будет содержать token пользователя, авторизовавшего приложение
Также в этот момент полезно сохранить полученный токен в БД либо в сессии, чтобы использовать их повторно:

``` ruby
current_user.token = @vk.token
current_user.save
# позже
@tph = TelphinApi::Client.new(current_user.token)
```

### Прочее

Если клиент API (объект класса `TelphinApi::Client`) был создан с помощью метода `TelphinApi.authorize`, он будет содержать информацию о времени истечения токена (`expires_in`). Получить их можно с помощью соответствующих методов:

``` ruby
@tph = TelphinApi.authorize
# => #<TelphinApi::Client:0x007fa578f00ad0>
tph.expires_at # => 2015-12-18 23:22:55 +0400
# можно проверить, истекло ли время жизни токена
tph.expired?   # => false
```

Чтобы создать короткий синоним `TPH` для модуля `TelphinApi`, достаточно вызвать метод `TelphinApi.register_alias`:

``` ruby
TelphinApi.register_alias
TPH::Client.new # => #<TelphinApi::Client:0x007fa578d6d948>
```

При необходимости можно удалить синоним методом `TelphinApi.unregister_alias`:

``` ruby
TPH.unregister_alias
TPH # => NameError: uninitialized constant VK
```

### Обработка ошибок

Если Телфин API возвращает ошибку, выбрасывается исключение класса `TelphinApi::Error`.

``` ruby
tph = TPH::Client.new
@tph.extensions.phone_call_events
# TelphinApi::Error: Telphin returned an error extension_invalid: 'Value supplied in the URI-Fragment as extension is invalid. The parameter must reference the number of an existing extension and cannot be set to @self.'
```

### Логгирование

`telphin_api` логгирует служебную информацию о запросах при вызове методов.
По умолчанию все пишется в `STDOUT`, но в настройке можно указать
любой другой совместимый логгер, например `Rails.logger`.

Есть возможность логгирования 3 типов информации,
каждому соответствует ключ в глобальных настройках.

|                        | ключ настройки  | по умолчанию | уровень логгирования |
| ---------------------- | --------------- | ------------ | -------------------- |
| URL запроса            | `log_requests`  | `true`       | `debug`              |
| JSON ответа при ошибке | `log_errors`    | `true`       | `warn`               |
| JSON удачного ответа   | `log_responses` | `false`      | `debug`              |

Таким образом, в rails-приложении с настройками по умолчанию в production
записываются только ответы сервера при ошибках;
в development также логгируются URL-ы запросов.


## Настройка

Глобальные параметры `telphin_api` задаются в блоке `TelphinApi.configure` следующим образом:

``` ruby
TelphinApi.configure do |config|
  # параметры, необходимые для авторизации средствами telphin_api
  # (не нужны при использовании сторонней авторизации)
  config.app_key      = '123'
  config.app_secret   = 'AbCdE654'
  config.site         = 'https://pbx.telphin.ru/uapi' # По умолчанию https://pbx.telphin.ru/uapi
  
  # faraday-адаптер для сетевых запросов
  config.adapter = :net_http
  
  # параметры для faraday-соединения
  config.faraday_options = {
    ssl: {
      ca_path:  '/usr/lib/ssl/certs'
    },
    proxy: {
      uri:      'http://proxy.example.com',
      user:     'foo',
      password: 'bar'
    }
  }
  # максимальное количество повторов запроса при ошибках
  config.max_retries = 2
  
  # логгер
  config.logger        = Rails.logger
  config.log_requests  = true  # URL-ы запросов
  config.log_errors    = true  # ошибки
  config.log_responses = false # удачные ответы
end
```

По умолчанию для HTTP-запросов используется `Net::HTTP`; можно выбрать
[любой другой адаптер](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb),
поддерживаемый `faraday`.

При необходимости можно указать параметры для faraday-соединения &mdash; например,
параметры прокси-сервера или путь к SSL-сертификатам.

Чтобы сгенерировать файл с настройками по умолчанию в rails-приложении,
можно воспользоваться генератором `telphin_api:install`:

``` sh
$ cd /path/to/app
$ rails generate telphin_api:install
```

## JSON-парсер

`telphin_api` использует парсер [Oj](https://github.com/ohler55/oj)

Также в библиотеке `multi_json` (обертка для различных JSON-парсеров,
которая выбирает самый быстрый из установленных в системе и парсит им)
`Oj` поддерживается и имеет наивысший приоритет; поэтому если он установлен
в системе, `multi_json` будет использовать именно его.

## Участие в разработке

Если вы хотите поучаствовать в разработке проекта, форкните репозиторий,
положите свои изменения в отдельную ветку, покройте их спеками
и отправьте мне pull request.

`telphin_api` тестируется под MRI `2.1.2`.
Если что-то работает неправильно, либо вообще не работает,
то это следует считать багом, и написать об этом
в [issues на Github](https://github.com/rootooz/telphin_api/issues).
