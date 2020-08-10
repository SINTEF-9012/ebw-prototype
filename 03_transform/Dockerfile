FROM alpine:3.10

RUN apk update
RUN apk add bash
RUN apk add openjdk7-jre

RUN wget -O  /usr/local/bin/kubetools https://github.com/kubemq-io/kubemqctl/releases/download/v1.3.0/kubetools_linux_386
RUN chmod +x /usr/local/bin/kubetools

COPY ./bash_scripts /code
COPY ./common_scripts /code
COPY ./common_py /code
COPY ./configs /code/configs

ENTRYPOINT ["/code/main.sh"]