Web prototype
============

使用 Vagrant 和 Slim Framework 建置 prototype 開發環境

內含下列套件

- PHP 5.6
- MariaDB
- Memcached
- MongoDB
- Redis

Requirement
-----------

先安裝 VirtualBox 和 Vagrant

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

Installation
------------

clone 下來之後，使用命令列到下載的目錄下，下指令即可安裝該開發環境

    vagrant up

等命令列跑完，在網址打 http://10.10.10.10/ ，可以看到 Work 的字眼，代表安裝成功了。

預設環境如下，如果想修改，都可以在 `Vagrantfile` 裡面找到對應的值：

- 私有 ip 是 `10.10.10.10`
- 裡面有 MariaDB ，帳號是 root ，密碼為 password
