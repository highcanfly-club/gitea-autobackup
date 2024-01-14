FROM debian:bullseye
COPY --from=highcanfly/odoo-bitnami-custom:latest /bin/busybox /bin/busybox
COPY --chmod=0744 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends postgresql-client bzip2 xz-utils 
RUN ln -svf /bin/busybox /usr/bin/sendmail
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]