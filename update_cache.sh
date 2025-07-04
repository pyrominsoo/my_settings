#!/bin/bash

find * -type d > .dir_cache;
find Notes -type l >> .dir_cache;
find Down -type l >> .dir_cache;
