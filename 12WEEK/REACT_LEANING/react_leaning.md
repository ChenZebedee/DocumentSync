# react 学习

## 搭建 React 开发环境

### 安装 fnm node多版本管理工具 以及安装 nodejs

```shell
# linux/macos
curl -fsSL https://fnm.vercel.app/install | bash
# windows 需要先安装scoop
# 安装 scoop
# set-executionpolicy remotesigned -scope currentuser
# Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
# scoop install fnm
# 推出shell之后重连
fnm install 20
```

### 创建 React 项目

```shell
npx create-react-app my-react-app
```

执行结果:

```shell
Need to install the following packages:
create-react-app@5.0.1
Ok to proceed? (y) y

npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm warn deprecated rimraf@2.7.1: Rimraf versions prior to v4 are no longer supported
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated fstream@1.0.12: This package is no longer supported.
npm warn deprecated uid-number@0.0.6: This package is no longer supported.
npm warn deprecated fstream-ignore@1.0.5: This package is no longer supported.
npm warn deprecated tar@2.2.2: This version of tar is no longer supported, and will not receive security updates. Please upgrade asap.

Creating a new React app in /root/coding/web/my-react-app.

Installing packages. This might take a couple of minutes.
Installing react, react-dom, and react-scripts with cra-template...


added 1478 packages in 1m

262 packages are looking for funding
  run `npm fund` for details

Initialized a git repository.

Installing template dependencies using npm...

added 63 packages, and changed 1 package in 6s

262 packages are looking for funding
  run `npm fund` for details
Removing template package using npm...


removed 1 package, and audited 1541 packages in 3s

262 packages are looking for funding
  run `npm fund` for details

8 vulnerabilities (2 moderate, 6 high)

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.

Created git commit.

Success! Created my-react-app at /root/coding/web/my-react-app
Inside that directory, you can run several commands:

  npm start
    Starts the development server.

  npm run build
    Bundles the app into static files for production.

  npm test
    Starts the test runner.

  npm run eject
    Removes this tool and copies build dependencies, configuration files
    and scripts into the app directory. If you do this, you can’t go back!

We suggest that you begin by typing:

  cd my-react-app
  npm start

Happy hacking!
```

### 目录解析

```
my-app/
├── node_modules/          # 项目依赖
├── public/                # 静态资源（HTML、图片等）
│   └── index.html         # 主 HTML 文件
├── src/                   # React 源代码
│   ├── App.js             # 主组件
│   ├── index.js           # 入口文件
│   ├── App.css            # 样式文件
│   └── ...                # 其他文件
├── package.json           # 项目配置和依赖
└── README.md              # 项目说明
```

## 开始学习编程

### JSX基础

用js写HTML ，JSX会被React翻译成HTML，样例：

```js
const element = <h1>Hello, React!</h1>;
```

--翻译成如下--->

```js
const element = React.createElement('h1', null, 'Hello, React!');
```

ERROR example:

```js
return (
  <h1>标题</h1>
  <p>段落内容</p>
);
```

### 组件

#### 函数组件

首字母必须大写，不然不识别，说是，函数就相当于类？垃圾东西

#### 类组件

类组件用于需要管理状态或复杂逻辑的场景，但现在更多的功能被 Hooks 取代。
