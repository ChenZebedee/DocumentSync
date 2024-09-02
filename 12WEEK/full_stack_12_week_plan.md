# 12周成为全栈工程师

## change log

## TODO List

- [ ] pypi是否可以搭建私库
- [ ] make 的使用与教程
- [ ] tox的使用与教程

> 2024-08-30: 首次计划,5个部分,每个部分平均两周多 包含(`python 爬虫 - AI`,`python web 接口`,`mongoDB 搭建与使用`,`sqlLite`,`react 基本使用与应用`)

> 2024-09-02: 更新文档,并添加包管理工具与项目创建工具分析

[[TOC]]

## 开发工具语言选择

- 前端:react
- 后端:python
- AI:python
- 版本库:gitlab
- python代码管理:poetry

## python 项目管理

### 学习资料

1. [图灵星球教程视频](https://www.bilibili.com/video/BV1si421m7EU/?spm_id_from=333.788)
2. [gitlab 官方文档](https://docs.gitlab.com/ee/ci/)
3. [CSDN Gitlab CI/CD：入门指南](https://blog.csdn.net/csfchh/article/details/122932753)
4. [poetry 依赖管理 官网](https://python-poetry.org/docs/)
5. [创建python项目shell](https://github.com/turingplanet/python-project-setup-tutorial/tree/main) - TODO 自己更新一个shell

### 项目管理包含东西

- 项目创建统一格式
- 代码版本管理 - git
- 代码错误分析 - pylint flake8
- 代码格式化方案 - Black
- 代码注释文档 - 准则 PEP 257
- 代码安全检测 - Bandit
- CI/CD 添加代码质量检测
- Git pre-commit 钩子,进行代码检测

#### 创建项目工具

基本上搜到的都是 `CookieCutter` `PyScaffold` `PyBuilder` `Poetry`

##### CookieCutter 创建项目

```shell
pip install cookiecutter
pip install tox wheel coverage sphinx flake8
# 以 github 上的 audreyr/cookiecutter-pypackage 为模板，再回答一堆的问题生成一个 Python 项目
cookiecutter gh:audreyr/cookiecutter-pypackage
```

运行需要回答一些问题,以下是我的创建模板:

```sh
You've downloaded /root/.cookiecutters/cookiecutter-pypackage before. Is it okay to delete and re-download it? [y/n] (y): y
  [1/14] full_name (Audrey Roy Greenfeld): shaoti #你的完整的名称
  [2/14] email (audreyr@example.com): shaoti.chen@outlook.com # 你的邮件
  [3/14] github_username (audreyr): ChenZebedee # github 上的名字
  [4/14] project_name (Python Boilerplate): cookiecutter_test # python项目名称
  [5/14] project_slug (cookiecutter_test): # 不知道,所以没填
  [6/14] project_short_description (Python Boilerplate contains all the boilerplate you need to create a Python package.): # 项目简短描述
  [7/14] pypi_username (ChenZebedee): # pypi是啥东西? 看后面
  [8/14] version (0.1.0): # 程序版本
  [9/14] use_pytest (n): # 是否需要使用test
  [10/14] use_pypi_deployment_with_travis (y): # 使用 travis 管理python的包
  [11/14] add_pyup_badge (n):
  [12/14] Select command_line_interface # 选择命令行的接口,我应该选择3的没有这些东西
    1 - Typer # 代码中调用代码的东西,然后在命令行中运行啥之类的
    2 - Argparse
    3 - No command-line interface
    Choose from [1/2/3] (1): 1
  [13/14] create_author_file (y): # 创建作者文件
  [14/14] Select open_source_license # 开源格式
    1 - MIT license
    2 - BSD license
    3 - ISC license
    4 - Apache Software License 2.0
    5 - GNU General Public License v3
    6 - Not open source
    Choose from [1/2/3/4/5/6] (1): 5

```

生成的目录结构

```sh
.
├── AUTHORS.rst
├── CODE_OF_CONDUCT.rst
├── CONTRIBUTING.rst
├── docs
│   ├── authors.rst
│   ├── conf.py
│   ├── contributing.rst
│   ├── history.rst
│   ├── index.rst
│   ├── installation.rst
│   ├── make.bat
│   ├── Makefile
│   ├── readme.rst
│   └── usage.rst
├── HISTORY.rst
├── LICENSE
├── Makefile
├── MANIFEST.in
├── pyproject.toml
├── README.rst
├── requirements_dev.txt
├── ruff.toml
├── src
│   └── cookiecutter_test
│       ├── cli.py
│       ├── cookiecutter_test.py
│       └── __init__.py
├── tests
│   ├── __init__.py
│   └── test_cookiecutter_test.py
└── tox.ini

5 directories, 27 files
```

项目构建与测试等功能

> 一定要先安装 tox wheel coverage sphinx flake8

```sh
$ make
clean                remove all build, test, coverage and Python artifacts
clean-build          remove build artifacts
clean-pyc            remove Python file artifacts
clean-test           remove test and coverage artifacts
lint                 check style
test                 run tests quickly with the default Python
test-all             run tests on every Python version with tox
coverage             check code coverage quickly with the default Python
docs                 generate Sphinx HTML documentation, including API docs
servedocs            compile the docs watching for changes
release              package and upload a release
dist                 builds source and wheel package
install              install the package to the active Python's site-packages

```

##### PyScaffold 使用

安装,以及创建项目命令:

```shell
pip install pyscaffold
putup pyscaffold-test
```

创建之后的目录结构如下:

```shell
$ tree pyscaffold-test
pyscaffold-test
├── AUTHORS.rst
├── CHANGELOG.rst
├── CONTRIBUTING.rst
├── docs
│   ├── authors.rst
│   ├── changelog.rst
│   ├── conf.py
│   ├── contributing.rst
│   ├── index.rst
│   ├── license.rst
│   ├── Makefile
│   ├── readme.rst
│   ├── requirements.txt
│   └── _static
├── LICENSE.txt
├── pyproject.toml
├── README.rst
├── setup.cfg
├── setup.py
├── src
│   └── pyscaffold_test
│       ├── __init__.py
│       └── skeleton.py
├── tests
│   ├── conftest.py
│   └── test_skeleton.py
└── tox.ini

6 directories, 22 files
```

使用 tox 构建项目,如何使用tox呢?

tox 是一种自动化测试工具

> Q: tox 怎么使用

> A:

##### PyBuilder 的使用与测试

安装以及创建项目

```shell
pip install pybuilder
mkdir pybuilder-test && cd pybuilder-test    # 项目目录需手工创建
pyb --start-project                          # 回答一些问题后创建所需的目录和文件
```

问题解析与回答选择

```shell
$ pyb --start-project
Project name (default: 'pybuilder-test') : # 项目名称,会根据文件夹名称自动设置
Source directory (default: 'src/main/python') : # 源码位置,可以自己设定,这个是比较好的
Docs directory (default: 'docs') : # 文档位置
Unittest directory (default: 'src/unittest/python') : # 单元测试位置
Scripts directory (default: 'src/main/scripts') : # 脚本放位置
Use plugin python.flake8 (Y/n)? (default: 'y') : Y # 是否使用 flake8 插件
Use plugin python.coverage (Y/n)? (default: 'y') : # 使用使用 coverage 插件
Use plugin python.distutils (Y/n)? (default: 'y') : # 是否使用 distutils 插件

Created 'setup.py'.

Created 'pyproject.toml'.
```

> Q: flake8 coverage distutils 各个插件干啥用的?

> A:

目录结构数

```shell
[$] <> tree
.
├── build.py
├── docs
├── pyproject.toml
├── setup.py
└── src
    ├── main
    │   ├── python
    │   └── scripts
    └── unittest
        └── python

8 directories, 3 files
```

##### poetry 的使用与分析

安装及创建目录

```shell
curl -sSL https://install.python-poetry.org | python3 -
poetry new poetry-test
```

创建完目录

```shell
tree poetry-test
poetry-test
├── poetry_test
│   └── __init__.py
├── pyproject.toml
├── README.md
└── tests
    └── __init__.py

3 directories, 4 files
```

##### 各个方式的目录缺点分析

- CookieCutter: 一个python项目,也太tm庞大了,这肯定是搞c的人搞的,而且还是用make打包,感觉有点四不像的样子
- PyScaffold: 还是显的很臃肿,基本上不咋使用
- pybuilder: 没有自动生成对应的main程序,只是创建了一个包
- poetry: 需要学习一下目录结构,当然都需要学习

##### 总结

显而易见,前两个,真的臃肿,而pybuilder没有创建文件,所以就poetry最好,而且最新

#### 代码静态检测

##### poetry - pylint

写完之后执行`poetry run pylint src/`即可进行代码静态检查

Q: neovim中用什么检查?能否套用poetry的运行
A: mason 中带有pylint的检测,可以直接使用

时候可以在 `Git pre-commit` 加上 `pylint`

## python 爬虫 - AI

### 学习资料

1. [爬虫教程视频](https://www.bilibili.com/video/BV1GH4y1g749/?spm_id_from=333.788)
2. [Beautiful Soup 4.12.0 文档](https://www.crummy.com/software/BeautifulSoup/bs4/doc.zh/)
3. [Requests: HTTP for Humans](https://docs.python-requests.org/en/latest/index.html)
4. [Requests: 让 HTTP 服务人类](https://requests.readthedocs.io/projects/cn/zh-cn/latest/)
5. [playwright 官方文档](https://playwright.dev/python/docs/intro)
6. AI爬虫 - TODO

## python web 接口

### 学习资料

1. [flask 3.0 官方文档](https://flask.palletsprojects.com/en/3.0.x/)
2. [flask 源码](https://github.com/pallets/flask/)
3. [flask 菜鸟教程](https://www.runoob.com/flask/flask-tutorial.html)
4. [django 5.1 官方文档](https://docs.djangoproject.com/en/5.1/)
5. [django 菜鸟教程](https://www.runoob.com/django/django-tutorial.html)
6. [fast api 官网](https://fastapi.tiangolo.com/)

## mongoDB 搭建与使用

### 学习资料

1. [mongoDB 官方文档](https://www.mongodb.com/zh-cn/docs/)
2. [mongoDB 菜鸟教程](https://www.runoob.com/mongodb/mongodb-tutorial.html)

## sqlLite

### 学习资料

1. [官方文档](https://www.sqlite.org/docs.html)
2. [菜鸟教程](https://www.runoob.com/sqlite/sqlite-tutorial.html)
3. [sqlLite github 源码地址](https://github.com/sqlite/sqlite)

## react 基本使用与应用

### 学习资料

1. [react 官方中文文档](https://zh-hans.react.dev/learn)
2. [react 菜鸟基础](https://www.runoob.com/react/react-tutorial.html)

## pypi 是什么

搜索,直接出来`Python Package Index`,看这个就知道,python的包索引

官网说 `Find, install and publish Python packages with the Python Package Index`

就类似 java 中的 maven ,docker中的docker hub

> Q: 那是否也可以搭建私库

> A:
