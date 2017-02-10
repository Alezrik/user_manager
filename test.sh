#!/bin/bash

mix ecto.create || exit -1
mix ecto.migrate || exit -1
MIX_ENV=test mix do deps.get, test
