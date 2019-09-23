FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
	openssh-client

ARG priv
ARG pub
ARG user
ARG server
ARG port
ARG zosdir

ENV RMVSDIR="${zosdir}"
ENV RMVSHOST="${server}"
ENV RMVSSCP=scp
ENV RMVSSCPOPTS="-P ${port}"
ENV RMVSSSH=ssh
ENV RMVSSSHOPTS="-p ${port}"
ENV RMVSUSER="${user}"

# copy credentials in from owning environment
RUN mkdir /root/.ssh/ && chmod 0700 /root/.ssh
RUN echo "${priv}" >/root/.ssh/id_rsa 
RUN echo "${pub}" >/root/.ssh/id_rsa.pub 
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa.pub
RUN ssh-keyscan -p ${port} ${server} >/root/.ssh/known_hosts

WORKDIR /usr/lpp/zoau/bin
COPY bin/* ./
RUN chmod +x *
ENV PATH="${PATH}:/usr/lpp/zoau/bin"

