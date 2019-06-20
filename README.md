# 15Five's Mirror PostgreSQL Image for CI

This image can be used to create a master-mirror environment
within CI services such as CircleCI as well as in a development
environment.

Below is an snippet from an example docker-compose.yml:

    version: '3.2'

    services:
        master:
            image: 15five/postgres.master
            ports:
                - "5433:5432"
            cap_add:
                - NET_ADMIN

        mirror1:
            image: 15five/postgres.mirror
            ports:
                - "5434:5432"
            cap_add:
                - NET_ADMIN
            links:
                - master
            depends_on:
                - master

