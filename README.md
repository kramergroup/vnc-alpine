# vnc-alpine - MatMod version

This container provides a [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing)-enabled container based on Alpine Linux.

The container is meant to serve a basis for containerised X11 applications. It has the following features:

- Openbox minimal Window Manager
- WBar dock

Based on Alpine Linux, the container is less than 150 MB in size. Most of this is the X11 window system.

## Usage

The container runs a VNC server on port 5900. This port has to be mapped for VNC clients to access it:

```bash
docker run -d -p 5900:5900 kramergroup/vnc-alpine
```

Once the container is running, point a VNC viewer to `localhost:5900`.

## User login

A connecting VNC client will have access to the **alpine/alpine** user's desktop.

### Adding Users

The usual `useradd/passwd` feature of linux is available. To add a user to a running container with name `vnc-alpine` use:

```bash
  docker exec -it vnc-alpine adduser <username>
```

## Openbox Window Manager

The container uses the [Openbox](https://en.wikipedia.org/wiki/Openbox) window manager.
Openbox is lightweight and easy to configure (via xml files). Programs are started using a right-click, which produces a menu with options.

## WBar dock

The [WBar](https://code.google.com/archive/p/wbar/) dock is installed. It can be configured via `assets/wbar/wbar.cfg`.

## Terminal

The container uses a fork of the [Suckless terminal](https://github.com/DenisKramer/st), which is based on Luke Smith's adaption of [st](https://github.com/shiva/st).
