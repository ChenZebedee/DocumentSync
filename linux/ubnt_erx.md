# ubnt_erx config

## add debin source
```shell
configure
set system package repository wheezy components 'main contrib non-free'
set system package repository wheezy distribution wheezy 
set system package repository wheezy url http://http.us.debian.org/debian
set system package repository wheezy-security components main
set system package repository wheezy-security distribution wheezy/updates
set system package repository wheezy-security url http://security.debian.org
commit
save
exit
```