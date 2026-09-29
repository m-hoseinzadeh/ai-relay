# Pinned, and pulled onto the host beforehand: ci-agent does not pull images on its own.
FROM nginx:1.29-alpine

COPY templates/ /etc/nginx/templates/

# The image's entrypoint renders templates/*.template into conf.d with envsubst, and with this set
# it also exports the container's DNS servers as NGINX_LOCAL_RESOLVERS for the `resolver` line.
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1
