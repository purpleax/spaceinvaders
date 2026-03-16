FROM nginx:alpine

# Copy game files into nginx web root
COPY index.html /usr/share/nginx/html/index.html
COPY config.json /usr/share/nginx/html/config.json
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1
