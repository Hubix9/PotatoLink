# Potatolink

This project is a simple implementation of a link shortening service.

## Features
- link shortening
- login/registration (create links with different expiration time depending on whether user is logged in or not)
- displaying a list of previously created links and their expiration time


## Installation

First clone the repository.

**Frontend setup**

Enter the "frontend" directory

Install all the required dependencies

```bash
npm install --dev
```

Build the frontend files

```bash
npm run build
```

The frontend is now ready to be served by the backend portion of the application

**Backend setup**

Install all the required dependencies

```bash
mix deps.get
```

build the project

```bash
mix build
```

That's it! Backend is ready to go

you can now run it from the _build directory
```bash
/your/path/to/the/project/directory/_build/dev/rel/potatolink/bin/potatolink start
```

## Known issues

The application has many avenues where it could be more efficient or structured differently (link access id generation for example, or the majority of frontend)

If you are going to run it on your server I advise you to put it behind a reverse proxy with rate limiting capabilities, since rate limiting hasn't been built in to the application

## Disclaimer
This project is not meant to run in an production environemnt