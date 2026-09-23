#!/bin/sh
set -eu
bin/doski eval "Doski.Release.migrate"
bin/doski eval "Doski.Release.seed"
bin/doski start
