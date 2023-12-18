# Chapter 7. Vuex 进阶

# 项目结构

Vuex 规定了一些需要遵守的规则

1. 应用层级的状态应该集中到一个 store 对象中
2. 提交 mutation 是更改状态的唯一方法，并且这个过程是同步的
3. 异步逻辑都要放在 action 中

如果 store 文件太大，可以将 action，mutation 和 getter 分割到单独文件中

对于大型应用， Vuex 相关代码最好分割到模块中

## 插件

Vuex 的 store 接收 `plugins` ，Plugin中会暴露出 mutation 的钩子。Vuex 的插件就是一个函数，它接收 store 作为唯一参数

```JavaScript
const myPlugin = store => {
  // 当 store 初始化后调用
  store.subscribe((mutation, state) => {
    // 每次 mutation 之后调用
    // mutation 的格式为 { type, payload }
  })
}


const store = new Vuex.Store({
  // ...
  plugins: [myPlugin]
})
```

### 插件内提交 Mutation

在插件中不允许直接修改状态——类似于组件，只能通过提交 mutation 来触发变化

### 生成 State 快照

有时候插件需要获得状态的“快照”，比较改变的前后状态。想要实现这项功能，你需要对状态对象进行深拷贝。

**生成状态快照的插件应该只在开发阶段使用**

### 内置 Logger 插件

Vuex 自带一个日志插件用于一般的调试

### 开启严格模式

开启严格模式，仅需在创建 store 的时候传入 `strict: true`

在严格模式下，无论何时发生了状态变更且不是由 mutation 函数引起的，将会抛出错误。这能保证所有的状态变更都能被调试工具跟踪到

**不要在发布环境下启用严格模式**！严格模式会深度监测状态树来检测不合规的状态变更——请确保在发布环境下关闭严格模式，以避免性能损失

### 表单处理

当在严格模式中使用 Vuex 时，在属于 Vuex 的 state 上使用 `v-model` 会比较棘手

如果在 input 中绑定一个 Vuex store 的对象，当输入框值发生变化时，就会尝试去修改这个对象，这在严格模式下是不允许的

用“Vuex 的思维”去解决这个问题的方法是：给 `<input>` 中绑定 value，然后侦听 `input` 或者 `change` 事件，在事件回调中调用一个方法来触发 mutation 函数

但是这种方式用起来并不是很简洁，那么我们可以用下面的方式

## 双向绑定的计算属性

使用带有 setter 的双向绑定计算属性，我们给计算属性设置好 getter / setter，这样就可以分别处理双向绑定计算属性的获取及更改了

### 测试&热重载

[测试 | Vuex](https://vuex.vuejs.org/zh/guide/testing.html#%E6%B5%8B%E8%AF%95-mutation)

[热重载 | Vuex](https://vuex.vuejs.org/zh/guide/hot-reload.html#%E5%8A%A8%E6%80%81%E6%A8%A1%E5%9D%97%E7%83%AD%E9%87%8D%E8%BD%BD)

