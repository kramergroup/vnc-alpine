FROM alpine:latest AS st-builder

RUN apk add --no-cache make gcc git freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev
RUN git clone https://github.com/DenisKramer/st.git /work
WORKDIR /work
RUN make

FROM alpine:latest AS xdummy-builder

RUN apk add --no-cache make gcc freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev
RUN apk add libressl linux-headers --no-cache
RUN apk add x11vnc --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/
RUN Xdummy -install

# ----------------------------------------------------------------------------

FROM alpine:latest

USER root

# Basic init and admin tools
RUN apk --no-cache add supervisor sudo \
    && addgroup alpine \
    && adduser  -G alpine -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && echo "alpine    ALL=(ALL) ALL" >> /etc/sudoers \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# Install X11 server and dummy device
RUN apk add --no-cache xorg-server xf86-video-dummy \
    && apk add libressl --no-cache \
    && apk add x11vnc --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY --from=xdummy-builder /usr/bin/Xdummy.so /usr/bin/Xdummy.so
COPY assets/xorg.conf /etc/X11/xorg.conf
COPY assets/xorg.conf.d /etc/X11/xorg.conf.d

# Openbox window manager
RUN apk --no-cache add openbox \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/openbox/mayday/mayday-arc /usr/share/themes/mayday-arc
COPY assets/openbox/mayday/mayday-arc-dark /usr/share/themes/mayday-arc-dark
COPY assets/openbox/mayday/mayday-grey /usr/share/themes/mayday-grey
COPY assets/openbox/mayday/mayday-plane /usr/share/themes/mayday-plane
COPY assets/openbox/rc.xml /etc/xdg/openbox/rc.xml
COPY assets/openbox/menu.xml /etc/xdg/openbox/menu.xml
COPY assets/openbox/autostart /etc/xdg/openbox/autostart

# A decent system font
RUN apk add --no-cache font-noto \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/fonts.conf /etc/fonts/fonts.conf

# st  as terminal
RUN apk add --no-cache freetype fontconfig xproto libx11 libxft libxext ncurses xsetroot \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY --from=st-builder /work/st /usr/bin/st
COPY --from=st-builder /work/st.info /etc/st/st.info
RUN tic -sx /etc/st/st.info

# A dock
RUN apk add --no-cache wbar
COPY assets/wbar/wbar.cfg /etc/wbar.d/wbar.cfg
COPY assets/wbar/wbar.sh /usr/local/bin/wbar.sh

# Configure init
COPY assets/supervisord.conf /etc/supervisord.conf

# Some other resources
RUN apk add --no-cache xset \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/xinit/Xresources /etc/X11/Xresources
COPY assets/xinit/xinitrc.d /etc/X11/xinit/xinitrc.d
COPY assets/x11vnc-session.sh /usr/bin/x11vnc-session.sh

USER alpine
WORKDIR /home/alpine
EXPOSE 5900

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
