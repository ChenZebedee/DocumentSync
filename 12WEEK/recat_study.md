# react 学习

## 创建新项目

### 使用npx创建目录

```shell
npx create-react-app my-react-app
```

### 运行

```shell
cd my-react-app
npm start
```

`npm start`

    Starts the development server.

`npm run build`

    Bundles the app into static files for production.

`npm test`

    Starts the test runner.

`npm run eject`

    Removes this tool and copies build dependencies, configuration files
    and scripts into the app directory. If you do this, you can’t go back!

### 目录结构

```shell
$ tree -I 'node_modules'
.
├── package.json
├── package-lock.json
├── public
│   ├── favicon.ico
│   ├── index.html
│   ├── logo192.png
│   ├── logo512.png
│   ├── manifest.json
│   └── robots.txt
├── README.md
└── src
    ├── App.css
    ├── App.js
    ├── App.test.js
    ├── index.css
    ├── index.js
    ├── logo.svg
    ├── reportWebVitals.js
    └── setupTests.js
```

`public/`: 存放静态文件，如 HTML、图片等。
`src/`: 存放 React 代码，包括组件、样式、逻辑等。大多数开发工作都会在这个目录中进行。
  `index.js`: 项目的入口文件。React 组件树会从这里开始渲染。
  `App.js`: 默认的主组件文件。
  `index.css`: 全局样式文件。

## 理解JSX
