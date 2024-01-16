mac 安装完 postgreSQL 后使用 ip 连接报以下错误
```
FATAL: no pg_hba.conf entry for host "10.96.1.11", user "postgres", database
"postgres", SSL off
```

### 由于没有正确配置远程连接，导致无法使用 ip 连接 postgreSQL
需要在 `pg_hba.conf` 文件中配置需要远程连接数据库的客户端的地址

### mac 下配置文件所在文件夹权限
由于 mac 下电脑用户无访问配置文件所在文件夹的全选，所以需要切换到 postgreSQL 用户进入文件夹并编辑文件

### mac 下配置文件所在路径

`/Library/PostgreSQL/16/data`

我们可以使用 `sudo -u postgres bash` 命令切换到 postgres（数据库用户名） 用户来执行命令

切换到 `/Library/PostgreSQL/16/data` 路径

使用 `vim pg_hba.conf` 打开并编辑配置文件，添加客户端 ip
[image](img/pg_hba.jpg)




