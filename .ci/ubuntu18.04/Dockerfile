FROM ubuntu:18.04

RUN apt-get update \ 
    && apt-get install -y wget git zip curl
RUN apt-get update \ 
    && apt-get install -y build-essential debhelper
RUN wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_21.0.5-1~ubuntu~trusty_amd64.deb -O /tmp/erlang.deb
RUN dpkg -i /tmp/erlang.deb || true
RUN apt-get -f install -y
RUN mkdir -p /root/.ssh/
# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emqx_ci.sh /
ADD ./files/emqx_nightly_ci.sh / 
ADD ./files/emqx_release_ci.sh /

RUN chmod +x /emqx_ci.sh /emqx_nightly_ci.sh /emqx_release_ci.sh

CMD ["/emqx_ci.sh"]
