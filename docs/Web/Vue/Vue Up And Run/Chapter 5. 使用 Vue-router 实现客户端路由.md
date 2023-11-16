# Chapter 5. 使用 Vue-router 实现客户端路由

对于大多数单页面应用，都推荐使用官方支持的[ vue-router 库](https://router.vuejs.org/zh/guide/)

### 基本用法

简单实例

HTML

```HTML
<script src="https://unpkg.com/vue/dist/vue.js"></script>
<script src="https://unpkg.com/vue-router/dist/vue-router.js"></script>

<div id="app">
  <h1>Hello App!</h1>
  <p>
    <!-- 使用 router-link 组件来导航. -->
    <!-- 通过传入 `to` 属性指定链接. -->
    <!-- <router-link> 默认会被渲染成一个 `<a>` 标签 -->
    <router-link to="/foo">Go to Foo</router-link>
    <router-link to="/bar">Go to Bar</router-link>
  </p>
  <!-- 路由出口 -->
  <!-- 路由匹配到的组件将渲染在这里 -->
  <router-view></router-view>
</div>
```

JavaScript

```JavaScript
// 0. 如果使用模块化机制编程，导入Vue和VueRouter，要调用 Vue.use(VueRouter)

// 1. 定义 (路由) 组件。
// 可以从其他文件 import 进来
const Foo = { template: '<div>foo</div>' }
const Bar = { template: '<div>bar</div>' }

// 2. 定义路由
// 每个路由应该映射一个组件。 其中"component" 可以是
// 通过 Vue.extend() 创建的组件构造器，
// 或者，只是一个组件配置对象。
// 我们晚点再讨论嵌套路由。
const routes = [
  { path: '/foo', component: Foo },
  { path: '/bar', component: Bar }
]

// 3. 创建 router 实例，然后传 `routes` 配置
// 你还可以传别的配置参数, 不过先这么简单着吧。
const router = new VueRouter({
  routes // (缩写) 相当于 routes: routes
})

// 4. 创建和挂载根实例。
// 记得要通过 router 配置参数注入路由，
// 从而让整个应用都有路由功能
const app = new Vue({
  router
}).$mount('#app')
```

通过对Vue 实例注入路由器，我们可以在任何组件内通过 `this.$router` 访问路由器，也可以通过 `this.$route` 访问当前路由

当 `<router-link>` 对应的路由匹配成功，将自动设置 class 属性值 `.router-link-active`

### 动态路由匹配

当我们需要把某种模式匹配到的所有路由全部映射到同一个组件时，我们可以在 `vue-router` 的路由路径中使用“动态路径参数”(dynamic segment) 来达到这个效果

```JavaScript
const User = {
  template: '<div>User</div>'
}

const router = new VueRouter({
  routes: [
    // 动态路径参数 以冒号开头
    { path: '/user/:id', component: User }
  ]
})
```

此时 `/user/foo`，`user/bar` 都会映射到相同的路由，一个“路径参数”使用冒号 `:` 标记。当匹配到一个路由时，参数值会被设置到`this.$route.params`，可以在每个组件内使用。

也可以在路由中设置多段“路径参数”，对应的值都会设置到 `$route.params` 中

| **模式**                        | **匹配路径**            | **$route.params**                      |
| ----------------------------- | ------------------- | -------------------------------------- |
| /user/:username               | /user/evan          | `{ username: 'evan' }`                 |
| /user/:username/post/:post_id | /user/evan/post/123 | `{ username: 'evan', post_id: '123' }` |

### 响应路由参数的变化

当使用路由参数时，原来的组件会被复用，这就意味着生命周期的钩子不会再次调用

如果需要对路由参数的变化作出响应，可以简单的watch `$route` 对象，或者使用2.2之后引入的 `beforeRouteUpdate` 导航守卫

### 捕获所有路由或404 Not fonud 路由

常规参数只会匹配 `/` 分割的 URL 片段中的字符。如果想匹配任意路径，可以使用通配符 （`*`）

当使用通配符路由时，应确保通配符路由放在最后，由路由 `{path: ‘*’}` 通常用于客户端的404错误。如果你使用了_History 模式_，请确保[正确配置你的服务器](https://router.vuejs.org/zh/guide/essentials/history-mode.html)

当使用通配符时 `$route.params` 内会自动添加一个名为 `pathMatch` 的参数，该参数包含了通配符匹配的部分

### 高级匹配模式

`vue-router` 使用 [path-to-regexp](https://github.com/pillarjs/path-to-regexp/tree/v1.7.0)作为路径匹配引擎，所以支持很多高级的匹配模式。如：动态路径参数、匹配零个或多个、一个或多个，甚至是自定义正则匹配

### 匹配优先级

当同一个路径可以匹配多个路由时，匹配的优先级按照路由定义顺序来决定

### 嵌套路由

app 最顶层设置的 `<router-view>` 作为最顶层出口，用来渲染最高级路由匹配到的组件。一个被渲染的组件也可以包含自己的 `<router-view>` 。

要在嵌套的出口中渲染组件，需要在 `VueRouter` 的参数中使用 `children` 配置，`children` 的配置同 `routes` 配置方式是一样的，同样的你可以通过这种方式来嵌套多层路由

### 编程式导航

除了使用 `<router-link>` 创建 a 标签来定义导航链接，我们还可以借助 router 的实例方法，通过编写代码来实现

| **声明式**                   | **编程式**            |
| ------------------------- | ------------------ |
| `<router-link :to="...">` | `router.push(...)` |

在Vue实例内部，可以通过 `$router` 来访问路由实例

- router.push(location, onComplete?, onAbort?) 向 history 中添加新记录
- router.releace(location, onComplete?, onAbort?) 替换掉当前的 history 记录
- router.go(n) 这个方法的参数是一个整数，意思是在 history 记录中向前或者后退多少步

### 命名路由

可以通过设置路由 name 属性来给路由添加名称来标识一个路由，在调用的时候通过传递 name 来查找路由

```JavaScript
const router = new VueRouter({
  routes: [
    {
      path: '/user/:userId',
      name: 'user',
      component: User
    }
  ]
})

<router-link :to="{ name: 'user', params: { userId: 123 }}">User</router-link>
router.push({ name: 'user', params: { userId: 123 } })
```

### 命名视图

如果需要在同级展示多个视图，而不是嵌套展示，那么可以通过命名视图来实现

```HTML
<router-view class="view one"></router-view>
<router-view class="view two" name="a"></router-view>
<router-view class="view three" name="b"></router-view>
```

```JavaScript
const router = new VueRouter({
  routes: [
    {
      path: '/',
      components: {
        default: Foo,
        a: Bar,
        b: Baz
      }
    }
  ]
})
```

### 重定向和别名

可以通过路由属性 redirect 设置路由重定向，属性 alias 可以设置路由别名

### 路由组件传参

使用 `props` 将组件和路由解耦

props 路由属性可以设置将路由参数设置为组件props值，这样可以时路由和组件进行解耦，以保证组件在任何地方都可使用

### 导航守卫

`vue-router` 提供的导航守卫主要用来通过跳转或取消的方式守卫导航

1. 导航被触发。
2. 在失活的组件里调用 `beforeRouteLeave` 守卫。
3. 调用全局的 `beforeEach` 守卫。
4. 在重用的组件里调用 `beforeRouteUpdate` 守卫 (2.2+)。
5. 在路由配置里调用 `beforeEnter`。
6. 解析异步路由组件。
7. 在被激活的组件里调用 `beforeRouteEnter`。
8. 调用全局的 `beforeResolve` 守卫 (2.5+)。
9. 导航被确认。
10. 调用全局的 `afterEach` 钩子。
11. 触发 DOM 更新。
12. 调用 `beforeRouteEnter` 守卫中传给 `next` 的回调函数，创建好的组件实例会作为回调函数的参数传入。

### 路由元信息

定义路由的时候可以配置 `meta` 字段

`routes` 配置中的每个路由对象为 **路由记录**。路由记录可以是嵌套的，因此，当一个路由匹配成功后，他可能匹配多个路由记录，我们可以通过遍历检查路由记录中的 `meta` 字段来做一些特定操作

### 过渡动效

`<router-view>` 是基本的动态组件，所以我们可以用 `<transition>` 组件给它添加一些过渡效果

```HTML
<transition>
  <router-view></router-view>
</transition>
```

还可以基于当前路由与目标路由的变化关系，动态设置过渡效果

