#!/bin/bash

psql -h 172.19.1.97 -U postgres -c 'CREATE USER eld;'
psql -h 172.19.1.97 -U postgres -c 'CREATE DATABASE eld;'
pg_restore --exit-on-error --verbose --dbname=eld -h 172.19.1.97 -U postgres eld-dump.tar
