# Trello Clone

«Trello Clone» — одностраничное канбан-приложение в духе Trello: регистрация, свои и общие доски, списки, карточки и совместная работа в реальном времени. Проект сделан по учебному разбору [Trello tribute with Phoenix and React](https://bigardone.dev/blog/2016/01/04/trello-tribute-with-phoenix-and-react-pt-1/).

Пользователь входит в систему, создаёт доски, приглашает других зарегистрированных пользователей и ведёт списки с карточками. Пока доска открыта, видны подключённые участники, а изменения сразу появляются у остальных.

## Стек

- Backend: Elixir, Phoenix, Ecto, PostgreSQL, Guardian (JWT), Phoenix Channels
- Frontend: Webpack, Sass, React, React Router, Redux (Redux Toolkit)
- База: PostgreSQL

## Как запустить локально

Нужны Elixir 1.17+, Erlang/OTP 27+ и PostgreSQL 14 или новее (локально проверено на PostgreSQL 17). В разработке база называется `doski_dev`, пользователь `postgres`, пароль `postgres`. Если у сервера включён `trust` для localhost, пароль не проверяется.

```powershell
mix setup
mix phx.server
```

Во втором терминале:

```powershell
cd frontend
npm install
npm start
```

Интерфейс: http://localhost:8080 или http://127.0.0.1:8080  
API: http://127.0.0.1:4000

При включённом VPN открывайте именно эти адреса. Сервер слушает и IPv4 (`127.0.0.1`), и IPv6 (`::1`): иначе часть VPN-клиентов «глотает» localhost и браузер показывает «Нет соединения с сервером».

Сборка интерфейса в `priv/static`, чтобы открывать приложение сразу с Phoenix:

```powershell
cd frontend
npm run build
mix phx.server
```

После этого сайт доступен на http://127.0.0.1:4000

Проверки:

```powershell
mix test
```

## Тестовые пользователи

| Почта | Пароль | Роль в сидах |
| --- | --- | --- |
| demo@example.com | parol12345 | Иван Петров, владелец доски «Практика: веб-разработка» и участник общей доски |
| maria@example.com | parol12345 | Мария Соколова, владелец доски «Совместная доска» |

## Репозиторий

https://github.com/Daniil9452/trello-clone

## Деплой

Ссылка на работающий сайт: _публикация на Render по `render.yaml`, ссылка добавляется после создания сервиса_.

Проект готов к выкладке на Render через `Dockerfile` и `render.yaml`:

1. Залейте репозиторий на GitHub.
2. В Render создайте Blueprint из `render.yaml` или Web Service с окружением Docker и базой PostgreSQL.
3. Задайте `DATABASE_URL`, `SECRET_KEY_BASE` (`mix phx.gen.secret`), `GUARDIAN_SECRET`, `PHX_HOST` и `ECTO_SSL=true`, если база требует SSL.
4. Секреты не храните в репозитории.

Локальный PostgreSQL без установленного сервера можно поднять так: `docker compose up -d`.

## Code Climate

[![Code Climate](https://codeclimate.com/github/Daniil9452/trello-clone/badges/gpa.svg)](https://codeclimate.com/github/Daniil9452/trello-clone)

Бейдж нужен для оценки 4 и 5. Репозиторий нужно один раз добавить в [Code Climate](https://codeclimate.com/github/Daniil9452/trello-clone): после анализа оценка должна быть A или B. Файл `.codeclimate.yml` уже лежит в корне.
