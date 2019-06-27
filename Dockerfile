FROM golang:1.12.1-stretch as builder

# Doing mostly what CI is doing here
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 648A4A16A23015EEF4A66B8E4052245BD4284CDD && \
    echo "deb https://repo.iovisor.org/apt/xenial xenial main" > /etc/apt/sources.list.d/iovisor.list && \
    apt-get update && \
    apt-get install -y libbcc linux-headers-amd64

COPY ./ /go/ebpf_exporter

RUN cd /go/ebpf_exporter && GOPATH="" GOPROXY="off" GOFLAGS="-mod=vendor" go install -v ./...

FROM debian:stretch-slim

RUN apt-get update && apt-get install -y gnupg

RUN apt-get install -y apt-transport-https && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 648A4A16A23015EEF4A66B8E4052245BD4284CDD && \
    echo "deb https://repo.iovisor.org/apt/xenial xenial main" > /etc/apt/sources.list.d/iovisor.list && \
    apt-get update && \
    apt-get install -y libbcc linux-headers-amd64

COPY --from=builder /root/go/bin/ebpf_exporter /usr/bin/ebpf_exporter

ENTRYPOINT [ "ebpf_exporter" ]
CMD [ "--config.file=/etc/ebpf_exporter/sgx.yaml" ]
