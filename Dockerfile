FROM pypy:2
MAINTAINER Shawn Nock <nock@nocko.se>

ENV APPNAME gifkeyer
EXPOSE 8080

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove ca-certificates wget

RUN useradd -m $APPNAME
WORKDIR /home/$APPNAME
COPY ./requirements.txt ./
RUN pip install -r requirements.txt && mkdir ./gifs ./public && chown $APPNAME ./gifs && chown $APPNAME ./public

ENV KEYDOWN_PIC keydown.jpg
ENV KEYUP_PIC keyup.jpg
COPY keyer.sh gifkeyer.py $KEYDOWN_PIC $KEYUP_PIC placeholder.png cache-source-images.sh ./
COPY public/* ./public/
RUN gosu $APPNAME ./cache-source-images.sh

CMD exec gosu $APPNAME twistd -n -y $APPNAME.py
