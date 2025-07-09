## systemd-tmpfiles

```
https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html

C+ - copy recursively and clobber
L  - link
L+ - link and clobber
z  - set mode
Z  - set mode recursively

L/+ <SRC>         -        -        -         - <TARGET>
C/+ <TARGET>      -        -        -         - <SRC>
z/Z <TARGET/GLOB> <mode>   [<user>] [<group>] - -
d   <PATH>        [<mode>] [<user>] [<group>] - -

%h - expands to user home
```
