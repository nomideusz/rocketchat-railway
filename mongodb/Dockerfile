FROM mongo:8.0.32
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY rs-setup.js /usr/local/share/rs-setup.js
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
