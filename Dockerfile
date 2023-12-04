FROM alpine:3.18

COPY .github/scripts/simple-shell-syntax-check.sh /usr/local/bin/simple-shell-syntax-check.sh

ENTRYPOINT [ "/usr/local/bin/simple-shell-syntax-check.sh" ]