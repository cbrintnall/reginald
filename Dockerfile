FROM elixir:1.10.3-slim

WORKDIR /app

COPY lib lib
COPY config config
COPY mix.exs mix.exs

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile

CMD [ "mix", "run", "--no-halt" ]