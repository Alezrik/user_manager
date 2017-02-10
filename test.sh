#!/bin/bash

mix ecto.create

mix test || exit -1