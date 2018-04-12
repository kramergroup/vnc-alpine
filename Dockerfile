FROM alpine:latest AS st-builder

RUN apk add --no-cache make gcc git freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev
RUN git clone https://github.com/DenisKramer/st.git /work
WORKDIR /work
RUN make

# ----------------------------------------------------------------------------

FROM danielguerra/alpine-vnc

USER root

# Configure init
COPY assets/supervisord.conf /etc/supervisord.conf

# Openbox window manager
COPY assets/openbox/mayday/mayday-arc /usr/share/themes/mayday-arc
COPY assets/openbox/mayday/mayday-arc-dark /usr/share/themes/mayday-arc-dark
COPY assets/openbox/mayday/mayday-grey /usr/share/themes/mayday-grey
COPY assets/openbox/mayday/mayday-plane /usr/share/themes/mayday-plane
COPY assets/openbox/rc.xml /etc/xdg/openbox/rc.xml
COPY assets/openbox/menu.xml /etc/xdg/openbox/menu.xml

# A decent system font
RUN apk add --no-cache font-noto
COPY assets/fonts.conf /etc/fonts/fonts.conf

# URxvt as terminal
# RUN apk add rxvt-unicode --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted
# COPY assets/urxvt/perl /usr/lib/urxvt/perl

# st  as terminal
RUN apk add --no-cache freetype fontconfig musl xproto libx11 libxft libxext ncurses
COPY --from=st-builder /work/st /usr/bin/st
COPY --from=st-builder /work/st.info /etc/st/st.info
RUN tic -sx /etc/st/st.info

# Some other resources
RUN apk add --no-cache xset
COPY assets/xinit/Xresources /etc/X11/Xresources
COPY assets/xinit/xinitrc.d /etc/X11/xinit/xinitrc.d
COPY assets/xorg.conf.d /etc/X11/xorg.conf.d

#RUN apk add --no-cache dbus
#RUN apk add dbus-x11 --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted
#RUN apk add arc-theme --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
#RUN apk add gnome-desktop --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted
#RUN apk add paper-icon-theme --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted
#RUN apk add adwaita-icon-theme --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted
#COPY assets/settings.ini /etc/gtk-3.0/settings.ini
