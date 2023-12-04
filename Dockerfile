FROM ubuntu:22.04

COPY .github/scripts/simple-shell-syntax-check.sh /usr/local/bin/simple-shell-syntax-check.sh
RUN chmod +x /usr/local/bin/simple-shell-syntax-check.sh

# install bash
RUN apt-get update && \
    apt-get install -y bash dash fish && \
    rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "/usr/local/bin/simple-shell-syntax-check.sh" ]
CMD [ "/usr/local/bin/simple-shell-syntax-check.sh" ]
