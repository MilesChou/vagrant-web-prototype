Web prototype
============

使用 Vagrant 和 Slim Framework 建置 prototype 開發環境

Installation
------------

先安裝 VirtualBox 和 Vagrant

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

clone 下來之後，使用命令列到下載的目錄下，下指令即可安裝該開發環境

    make

等命令列跑完，在網址打 `http://33.33.33.33/` ，可以看到 Work 的字眼，代表安裝成功了。

預設環境如下，如果想修改，都可以在 Vagrantfile 裡面找到對應的值：

- 私有 ip 是 `33.33.33.33`
- 裡面有 MySQL ，帳號是 root ，密碼為空密碼
- 沒有設定 port 轉遞
