# GIT_NOTE

## Command line instructions

```bash
Git global setup
git config --global user.name ""
git config --global user.email ""
```

## Create a new repository

```bash
git clone
cd Spring-boot-mask
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master
```

## Existing folder

```bash
cd existing_folder
git init
git remote add origin
git add .
git commit -m "Initial commit"
git push -u origin master
```

## Existing Git repository

```bash
cd existing_repo
git remote add origin
git push -u origin --all
git push -u origin --tags
```

## 忽略修改同步

```bash
git fetch --all
git reset --hard origin/master
git pull origin master
```

## GIT免密设置

```bash
在项目目录下面的 .git/config 文件末尾添加
[credential]
    helper = store
之后输入一次密码
```