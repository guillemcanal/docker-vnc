# Docker VNC server 

An Ubuntu graphical environment using the [i3](https://i3wm.org/) windows manager 
which display maximized applications.

Applications can be accessed with any VNC viewer.

- On a Mac, [VNC connect](https://www.realvnc.com/en/connect/download/viewer/) is highly recommended
- On a Linux distro, please use [TigerVNC](https://tigervnc.org/)'s `vncviewer`

## Usage

Run `xfce4-terminal` by default.

`docker run -d --name vnc -p 5900:5900 gcanal/vcn`  

You can connect to the remote VNC session by connecting to `localhost:5900`

> **Note**: The default password is `changeme`,  
> you can peek a new one by using `-e VNC_PASS=here_your_new_password`

## Detailed usages

### Preserve your user's home directory

When you discard a container using `docker stop vnc && docker rm vnc`, 
by default, all your work will be lost.

To prevent it, you can leverage a docker volume to preserve the user's home directory.

`docker run -d --name vnc -p 5900:5900  -v workspace:/home/user gcanal/vcn`  

> **⚠ Caution** : I won't recommend mounting a directory from your host machine,
> instead, use a docker volume  as demonstrated above.

### Customize the default user

By default, the container create a user which look like this:

```shell
$ id
> uid=1000(user) gid=1000(user) groups=1000(user)
```

You can customize the user creation process by using environment variables:

|    Name    |                Description                | Default value |
|------------|-------------------------------------------|---------------|
| USER_NAME  | User name                                 | user          |
| USER_UID   | User UID                                  | 1000          |
| USER_GROUP | User primary group name                   | $USER_NAME    |
| USER_GID   | User primary group GID                    | $USER_UID     |
| USER_SHELL | User's login shell (available: bash, zsh) | /bin/bash     |
| HOME       | User's home directory                     | /home/user    |

Example:

```shell
docker run --rm -d --name vnc \
-e USER_NAME=jane \
-e USER_UID=1001 \
-e USER_GROUP=jane \
-e USER_GID=1001 \
-e USER_SHELL=/bin/zsh \
-e HOME=/home/jane \
gcanal/vnc
```

### Adjust the screen geometry and DPI

#### When creating a new container

By default, applications are run on a `1280x1024` screen, with a dpi of `96`.

You can customize the default screen geometry and dpi 
using environment variables before starting your container.

```shell
# A geometry and dpi adapted for retina screens
docker run --rm -d --name vnc \
-e VNC_GEOMETRY=2880x1800 \
-e VNC_DPI=180 \
gcanal/vnc
```

#### For an existing container

The geometry can although be ajusted dynamically:

`docker exec -ti vnc change-geometry DISPLAY_NUM WIDTH HEIGHT REFRESH_RATE`

|      Name      |          Description          | Default value |
|----------------|-------------------------------|---------------|
| `DISPLAY_NUM`  | The X11 display number        | `0`           |
| `WIDTH`        | The screen width in pixels    | `1280`        |
| `HEIGHT`       | The screen height in pixels   | `800`         |
| `REFRESH_RATE` | The screen refresh rate in Hz | `60`          |

#### HiDPI on a retina display

Running Docker GUI applications on MacOS which look nice and crisp on retina display and that fell right proven challenging.

To be documented...

## Customization

This project come with a [default theme](https://github.com/nana-4/materia-theme) and support colored emoji, it may not be suitable to you.

For now, it's not customizable, but it MAY be in the future.

