# Chapter 4. render 函数和 JSX

### 基础

Vue 推荐在大多数情况下使用模板来创建 HTML，但是一些复杂的场景中，需要 JavaScript 的完全编程能力，则可以使用 **渲染函数**

例如只能通过 level 的 prop 动态生成标题（heading）组件时，可以通过以下方式来实现

```JavaScript
Vue.component('anchored-heading', {
	render: function(createElement){
		return createElement(
			'h' + this.level, // 标签名称
			this.$slots.default // 子节点数据
		)
	},
	props: {
		level: {
			type: Number,
			required: true
		}
	}
})
```

向组件中传递不带 `v-slot` 指令的子节点时，比如 `anchored-heading` 中的 `Hello world!`，这些子节点被存储在组件实例中的 `$slots.default` 中，详细请参见： [实例Property](https://cn.vuejs.org/v2/api/#%E5%AE%9E%E4%BE%8B-property)

render函数优于template的一个很大的优势，就是在template中动态设置标签名称并不是那么容易的，并且代码可读性也不好。<{{ tagName }}>写法也是无效的

### 虚拟 DOM

Vue 通过建立一个**虚拟 DOM** 来追踪自己要如何改变真实 DOM

`createElement返回的`其实不是一个实际的 DOM 元素。它更准确的名字可能是 `createNodeDescription`，因为它所包含的信息会告诉 Vue 页面上需要渲染什么样的节点，包括及其子节点的描述信息。我们把这样的节点描述为“虚拟节点 (virtual node)”，也常简写它为“**VNode**”。“虚拟 DOM”是我们对由 Vue 组件树建立起来的整个 VNode 树的称呼。

### render 函数中 createElement 的参数

```JavaScript
// @returns {VNode}
createElement(
  // {String | Object | Function}
  // 一个 HTML 标签名、组件选项对象，或者
  // resolve 了上述任何一种的一个 async 函数。必填项。
  'div',

  // {Object}
  // 一个与模板中 attribute 对应的数据对象。可选。
  {
    // (详情见下一节)
  },

  // {String | Array}
  // 子级虚拟节点 (VNodes)，由 `createElement()` 构建而成，
  // 也可以使用字符串来生成"文本虚拟节点"。可选。
  [
    '先写一些文字',
    createElement('h1', '一则头条'),
    createElement(MyComponent, {
      props: {
        someProp: 'foobar'
      }
    })
  ]
)
```

- html 标签：标签名称是最简单的，也是唯一一个必需的参数。它可以是一个字符串，或是一个返回字符串的函数
- 数据对象：一个与模板中 attribute 对应的数据对象， 正如 `v-bind:class` 和 `v-bind:style` 在模板语法中会被特别对待一样，它们在 VNode 数据对象中也有对应的顶层字段。该对象也允许你绑定普通的 HTML attribute，也允许绑定如 `innerHTML` 这样的 DOM property (这会覆盖 `v-html` 指令)
- 子虚拟节点：VNode 必须唯一，组件树中所有的 VNode 必须是唯一的，createElement 字节点中使用的所有VNode必须是唯一的，不能实例化一个而在子节点中重复使用多次

渲染函数中没有与 `v-model` 的直接对应——你必须自己实现相应的逻辑

### JSX

如果你写了很多 `render` 函数，可能会觉得子虚拟节点参数的结构很复杂通过 createElement的方式来编写虚拟节点的结构很麻烦的话，也可以通过添加[Bable 插件](https://github.com/vuejs/jsx) 在Vue中使用 JSX 语法

```JavaScript
render: function (h) {
    return (
      <AnchoredHeading level={1}>
        <span>Hello</span> world!
      </AnchoredHeading>
    )
  }
```

### 函数式组件

一些简单的组件，没有任何状态管理，不需要监听任何状态，也没有生命周期方法的话，可以将组件标记为 functional，这意味着它无状态（没有响应式数据），也没有实例（没有 this 上下文）

```JavaScript
Vue.component('my-component', {
  functional: true,
  // Props 是可选的
  props: {
    // ...
  },
  // 为了弥补缺少的实例
  // 提供第二个参数作为上下文
  render: function (createElement, context) {
    // ...
  }
})
```

组件需要的一切都是通过 `context` 参数传递，它是一个包括如下字段的对象：

- `props`：提供所有 prop 的对象
- `children`：VNode 子节点的数组
- `slots`：一个函数，返回了包含所有插槽的对象
- `scopedSlots`：(2.6.0+) 一个暴露传入的作用域插槽的对象。也以函数形式暴露普通插槽。
- `data`：传递给组件的整个[数据对象](https://cn.vuejs.org/v2/guide/render-function.html#%E6%B7%B1%E5%85%A5%E6%95%B0%E6%8D%AE%E5%AF%B9%E8%B1%A1)，作为 `createElement` 的第二个参数传入组件
- `parent`：对父组件的引用
- `listeners`：(2.3.0+) 一个包含了所有父组件为当前组件注册的事件监听器的对象。这是 `data.on` 的一个别名。
- `injections`：(2.3.0+) 如果使用了 [`inject`](https://cn.vuejs.org/v2/api/#provide-inject) 选项，则该对象包含了应当被注入的 property。

在添加 `functional: true` 之后，需要更新我们的锚点标题组件的渲染函数，为其增加 `context`参数，并将 `this.$slots.default` 更新为 `context.children`，然后将 `this.level` 更新为 `context.props.level`。

官方文档：[渲染函数&JSX](https://cn.vuejs.org/v2/guide/render-function.html)

