# 通过wsl的nvim打开文件

[[TOC]]

## 配置注册表

### 配置文件夹与名字

1. 在`计算机\HKEY_CLASSES_ROOT\*\shell`添加一项 `neovim`
2. 点击 `neovim` 项，修改 `neovim` 右边的默认的值添加 `Open thith neovim`,这个值表示在右键中显示的内容
3. 右边空白处`右键` -> `新建` -> `字符串值`,修改名称为
   `Icon`,这个值会存图标位置。
4. 修改`Icon` 值，如`"D:\vim.ico"`,引号不能忘记
5. 在左边列表中，右键点击之前创建的`neovim`, `新建` -> `项` ,名称取为 `command`
6. 左键点击刚刚创建的`command` 项，修改默认的值，代表这个命令要运行什么参数，如我使用的是neovim，就添加`wt Debian.exe run nvim $(wslpath  '%1')`

### 一些内容的解析

* >`wt` 代表win10中添加的`终端`程序
* >`Debian.exe` 代表wsl的默认终端，如果你安装ubnutu，那就使用如`ubnutu22.04.exe`
