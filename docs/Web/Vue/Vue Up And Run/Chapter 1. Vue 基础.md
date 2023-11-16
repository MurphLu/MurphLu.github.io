# Chapter 1. Vue 基础

### 安装设置：

简单引用

```HTML
<html>
    <head>
        <title>hello</title>
    </head>
    <body>
        <!-- vue app 根节点 vue app 不能在body上进行初始化-->
        <div id="app"></div>
        <!-- vue cdn 引用 -->
        <script src="https://unpkg.com/vue"></script>
        <script>
            new Vue({
                el: "#app",
                created(){}
            });
        </script>
    </body>
</html>
```

上述方法只对简单页面比较友好，涉及到更加复杂的场景需要引入webpack打包工具以及使用一系列其他特性时这种方式就不适用了

### vue-loader 和 webpack

vue-loader 是webpack的一个加载器，用来在webpack打包过程中加载 Vue 文件（其中包含了HTML，JavaScript，CSS），或者可以直接使用脚手架vue-cli来完成vue开发的基础配置

### 模板语法

Vue.js 使用了基于 HTML 的模板语法，允许开发者声明式地将 DOM 绑定至底层 Vue 实例的数据。所有 Vue.js 的模板都是合法的 HTML，所以能被遵循规范的浏览器和 HTML 解析器解析。

{{ msg }} ， 数据绑定最常见的形式就是使用“Mustache”语法 (双大括号) 的文本插值

Mustache 标签将会被替代为对应数据对象上 `msg` property 的值。无论何时，绑定的数据对象上 `msg` property 发生了改变，插值处的内容都会更新。

指令 (Directives) 是带有 `v-` 前缀的特殊 attribute。指令 attribute 的值预期是**单个 JavaScript 表达式** (`v-for` 是例外情况，稍后我们再讨论)。指令的职责是，当表达式的值改变时，将其产生的连带影响，响应式地作用于 DOM。

### v-if VS v-show

v-if指令的值为 false，那么这个元素不会被插入 DOM

v-show指令则通过使用CSS 样式来控制元素的显示/隐藏

因为使用v-if隐藏的内部元素不会被显示，Vue不会尝试生成对应的HTML代码；而对于v-show指令，事实并非如此。这意味着隐藏尚未加载的内容时，v-if指令更好一些

此外，同 v-if 一同使用的还有 v-else-if 和 v-else

使用 v-if  会有额外的性能开销，因为在每次条件变化对应插入或移除元素时，都需要生成元素内部的 DOM 树。v-show 除了在初次创建时的开销，没有其他额外开销，如果需要频繁切换内容时，选择 v-show 是比较好的

如果元素之中包含图片，使用v-show 会更好，因为如果元素的 v-show 为false 的话，可以在图片显示之前就去加载它，而不是像 v-if 那样，当元素显示出来时才开始构建元素 DOM 树，并加载其中的内容

### 模板中的循环

v-for 指令用来遍历一个数组或对象，将指令所在的元素循环输出到页面上

### 属性绑定

v-bind 可以接收参数，并将参数值绑定到一个 HTML 属性上

`<button v-bind:type="buttonType"></button>`

或者简写为：

`<button :type="buttonType"></button>`

***::Tips：无论选择使用v-bind还是简写语法，尽量保持一致。在某些地方使用v-bind，而在另外的地方又使用简写语法，这样会让代码变得有些凌乱。::***

### 响应式

Vue 除了在一开始创建 HTML，Vue 同时还监控 data 对象的变化，并在数据变化时更新 DOM。

响应式的实现

Vue 修改了每个添加到 data 上的对象，当对象发生变化时 Vue 会收到通知，从而实现响应式。对象的每个属性都会呗替换为 getter 和 setter 方法，因此可以像使用正常对象一样使用它，但当你修改这个属性时，Vue会知道它发生了变化。

例如： `const data = { userId: 10};`

使用 Object.defineProperty() 覆写这个属性：

```JavaScript
const storedData = {};
storedData.userId = data.userId;
Object.defineProperty(data, 'userId', {
	get(){
		return storedData.userId;
	},
	set(value) {
		console.log('User id changed');
		sotredData.userId = value;
	},
	configurable: true,
	enumerable: true
});
```

上述代码就展现了 vue 的实现思路

同时 Vue 还使用代理方法封装了被观察的数组对象上的一些数组方法，来观察数组方法的调用，当调用这些方法的时候 vue 会及时知道数组的变化并触发必要的视图更新

注意事项：

1. 属性的 getter/setter 是在 Vue 实例初始化的时候添加的，所以直接为对象添加属性并不能使属性成为响应式的

最简单的办法是在初始化的时候在对象上定义好这个属性，并将值设为 undefined

或者，使用 `Object.assign()` 创建一个新的对象来覆盖原有对象

再或者，Vue 提供了 `Vue.set()` 方法，可以使用该方法将属性设置为响应式的

2. 不能直接使用索引来设置数组元素

可以使用 `.splice()` 方法移除旧元素并添加新元素

或者，使用 `Vue.set()`

3. 设置数组长度

不可使用JavaScript方法直接设置数组长度，vue 无法检测到对数组对象的更改，可以使用 `.splice()` 来操作，但是该方法只能用来缩短数组

### 双向数据绑定

v-bind 只能通过显示出来的值来反应 data 中所存储的值，但是不能通过UI上对值的修改来反向改变 data 中的值，要实现这个功能就需要通过 v-model 来实现双向数据绑定

```HTML
<div id="app">
	<input type="text" v-model="inputText">
	<p> inputText: {{ inputText }} </p>
</div>
```

data 中的值会反应在 input 的 value 上，同时对于 input 中的输入也会反向改变 data  中对应属性的值

### 动态设置 HTML

使用 {{ }} 插入对应的值时，其中的 HTML 字符会被自动转义，入过想直接插入一段 HTML 代码的话需要使用  `<div v-html="myHtml"></div> 这种形式`，无论 “myHtml”中包含什么内容，都不会被转义，而是直接输出到页面

但是这一功能需要慎用，有可能会暴露在 XSS 风险中

### 方法

在 Vue 模板里，函数被定义为方法来使用，只要将一个函数存储为 methods 对象的一个属性，就可以在模板中使用它

```JavaScript
<script>
export default {
  data() {
    return {
      hours: new Date().getHours(),
      greetee: "good"
    };
  },
  methods: {
    generatorHelloMessage() {
      if(this.hours < 12) { 
        return "Morning";
      } else if (this.hours >= 12 && this.hours < 18) {
        return "Afternoon";
      } else {
        return "evening";
      }
    }
  }
};
</script>
```

除了在插值中使用方法，还可以将其用在属性绑定中，甚至任何可以使用 JavaScript 表达式的地方都可以使用方法

在方法中 this 指向该方法所属的组件，可以使用 this 访问对象的 data 对象的属性和其他方法

### 计算属性

计算属性介于 data 对象属性 和 方法 之间，可以像访问 data 对象属性一样去访问计算属性，但是需要以函数的方式定义它

不论在方法或者其他计算属性，抑或是这个组件的任何地方，都可以通过 this 来访问这个计算属性

当计算属性所使用的 data 属性发生变化时，计算属性的值也会同事发生变化

除了明显的语法区别之外，计算属性和方法的区别体现在：

1. 计算属性会被缓存，只有计算属性的依赖发生变化时计算属性的代码才会被执行获取新值，否则会一直使用被缓存的值，但是方法则是每次调用都会执行一次
2. 计算属性可以通过将函数改为带有get set 属性的对象，来对计算属性进行赋值

data VS 计算属性 VS 方法

|      | 可读   | 可写    | 可接收参数 | 需要运算  | 有缓存          |
| ---- | ---- | ----- | ----- | ----- | ------------ |
| data | true | true  | false | false | 不需要运算，也谈不上缓存 |
| 方法   | true | false | true  | true  | false        |
| 计算属性 | true | true  | false | true  | true         |

### 侦听器

侦听器可以用来监听 data 对象属性或者计算属性的变化

在 Vue 中，计算属性会比侦听器更好一些，同设置数据然后监听它的变化相比，使用一个带有 setter 的计算属性会是更好的选择。

虽然大部分简单例子用不到侦听器，但其很适合用来处理异步操作

可以使用  `.` 操作符来监听对象某个属性的变化

当监听的属性发生变化时，侦听器会被传入两个参数 `（val, oldVal）` 用来了解该属性到底发生了什么变化

当监听一个对象的时候，可以监听整个对象的变化，这种操作叫做深度监听

```JavaScript
watch:{
	formData:{
		handler(){
			console.log();
		},
		deep: true
	}
}
```

### 过滤器

过滤器用来在模板中处理数据，可以用链式调用在一个表达式中使用过个过滤器

过滤器除了在插值中使用，还可以在 v-bind 中使用

可以在模板中的 filters 对象中定义过滤器，也可以通过 `Vue.filter()` 来注册全局过滤器

### 使用 refs 获取 DOM

通过设置元素的 ref 属性，就可以直接通过 `this.$refs.<属性值>`  来获取对应的 DOM 元素

### 输入和事件

可以使用 v-on 指令将事件侦听器绑定到元素上，`v-on:click=“testFunc”`   原生 DOM 事件对象会作为第一个参数传入绑定的方法中。如果使用内联代码，也可以通过$event 来访问事件对象。

`v-on:click` 也可以使用简写形式 `@click`

事件修饰符

可以使用很多修饰符来修改事件侦听器或者事件本身，比如 `v-on:click.once`

- `.stop` - 调用 `event.stopPropagation()`。阻止事件继续传播，避免在父级元素上触发事件
- `.prevent` - 调用 `event.preventDefault()`。阻止事件默认行为
- `.capture` - 添加事件侦听器时使用 capture 模式。
- `.self` - 只当事件是从侦听器绑定的元素本身触发时才触发回调。
- `.{keyCode | keyAlias}` - 只当事件是从特定键触发时才触发回调。
- `.native` - 监听组件根元素的原生事件。
- `.once` - 只触发一次回调。
- `.left` - (2.2.0) 只当点击鼠标左键时触发。
- `.right` - (2.2.0) 只当点击鼠标右键时触发。
- `.middle` - (2.2.0) 只当点击鼠标中键时触发。
- `.passive` - (2.3.0) 以 `{ passive: true }` 模式添加侦听器

### 生命周期钩子

- `beforeCreated` - `function`, 在实例初始化之后,进行数据侦听和事件/侦听器的配置之前同步调用。
- `created` - `function`, 在实例创建完之后立即同步调用，此时 数据侦听、计算属性、方法、事件/侦听器的回调函数 都以配置完毕，但是挂载阶段还未开始，并且 `$el` property 目前尚不可用
- `beforeMount` - `function`, 挂载开始之前被调用，相关的 `render` 函数首次被调用
- `mounted` - function, 实例被挂载之后调用，但是 `mounted` 并不能保证所有的子组件挂载完成，如果想要等到整个视图渲染完成再进行其他操作，可以在 `mounted` 中使用 `this.$nextTick(function(){})` 来执行对应操作
- `beforeUpdate` - `function`, 在数据发生改变之后，DOM 被更新之前调用。
- `updated` - `function`, 在数据更改导致虚拟 DOM 重新渲染和跟新完毕之后被调用，多数情况下，并不会使用这个钩子，如果需要根绝数据做对应的状态改变，最好是通过 计算属性 或者 watcher 来实现，`updated` 同 `mounted` 一样，也不能保证所有子组件也都被重新渲染完毕，如果需要在所有子组件渲染完毕执行一些特定操作，那么需要在 `updated` 方法中使用`this.$nextTick(function(){})` 来执行对应操作
- `activated` - `function`， 被 keep-alive 缓存的组件在激活时调用
- `deactivated` - `function`, 被 keep-alive 缓存的组件失活时调用
- `beforeDestory` - `function`, 实例销毁之前调用。在这一步，实例任然完全可用
- `destroyed` - `function`, 实例销毁后调用。该钩子被调用后，对应 Vue 实例的所有指令都被解绑，所有事件监听都被移除，所有子实例也都被销毁
- `errorCaptured` - `(err: Error, vm: Component, info: string) => ?boolean`，v2.5.0+新增，在捕获一个来自后代组件的错误时被调用。此钩子会收到三个参数：错误对象、发生错误的组件实例以及一个包含错误来源信息的字符串。此钩子可以返回 `false` 以阻止该错误继续向上传播。

### 自定义指令

除了 Vue 内置的一些指令 例如： v-if, v-model, v-html，Vue 也支持创建自定义指令，如果想对 DOM 进行某些操作时，可以使用自定义指令来实现。

添加一个指令类似于添加一个过滤器： 可以将它传入 Vue 实例或者组件的 `directives` 属性，或者使用 `Vue.directive()` 注册一个全局指令。需要传入指令的名字，以及一个包含钩子函数的对象，这些钩子函数会在设置了该指令的元素的生命周期的各个阶段被触发

```JavaScript
Vue.directive('my-directive', {
	bind(el){

	},
	update(){
	}
})
```

指令钩子函数

- bind,  在指令绑定到元素时被调用
- inserted,  在绑定的元素被添加到父节点时被调用——但和mounted一样，此时还不能保证元素已经被添加到DOM上。可以使用`this.$nextTick`来保证这一点
- update,  在绑定该指令的组件节点被更新时调用，但是该组件的子组件可能此时还未更新。
- componentUpdated,  和updated钩子类似，但它会在组件的子组件都更新完成后调用
- unbind,  用于指令的拆除，当指令从元素上解绑时会被调用

指令中最常用的为 bind 和 update。同时 Vue 也提供了只实现这两个钩子的简便写法

```JavaScript
Vue.directive('my-directive', (el)=>{
	// bind 和 update 都会触发该实现
})
```

### 钩子函数的参数

指令钩子函数会被传入以下参数：

- `el`：指令所绑定的元素，可以用来直接操作 DOM。
- `binding`：一个对象，包含以下 property：
   - `name`：指令名，不包括 `v-` 前缀。
   - `value`：指令的绑定值，例如：`v-my-directive="1 + 1"` 中，绑定值为 `2`。
   - `oldValue`：指令绑定的前一个值，仅在 `update` 和 `componentUpdated` 钩子中可用。无论值是否改变都可用。
   - `expression`：字符串形式的指令表达式。例如 `v-my-directive="1 + 1"` 中，表达式为 `"1 + 1"`。
   - `arg`：传给指令的参数，可选。例如 `v-my-directive:foo` 中，参数为 `"foo"`。
   - `modifiers`：一个包含修饰符的对象。例如：`v-my-directive.foo.bar` 中，修饰符对象为 `{ foo: true, bar: true }`。
- `vnode`：Vue 编译生成的虚拟节点。移步 [VNode API](https://cn.vuejs.org/v2/api/#VNode-%E6%8E%A5%E5%8F%A3) 来了解更多详情。
- `oldVnode`：上一个虚拟节点，仅在 `update` 和 `componentUpdated` 钩子中可用。

动态指令参数

指令的参数可以是动态的。例如，在 `v-mydirective:[argument]="value"` 中，`argument` 参数可以根据组件实例数据进行更新！这使得自定义指令可以在应用中被灵活使用。

对象字面量

如果指令需要多个值，可以传入一个 JavaScript 对象字面量。记住，指令函数能够接受所有合法的 JavaScript 表达式。

指令详细参见： [Vue 自定义指令](https://cn.vuejs.org/v2/guide/custom-directive.html)

### 过渡和动画

Vue 提供了 `transition` 的封装组件，在下列情形中，可以给任何元素和组件添加进入/离开过渡

- 条件渲染 (使用 `v-if`)
- 条件展示 (使用 `v-show`)
- 动态组件
- 组件根节点

```HTML
<template>
  <div>
    <button v-on:click="show = !show">淦</button>
    <transition name="fade">
      <p v-if="show">hello</p>
    </transition>
  </div>
</template>

<script>
export default {
  data() {
    return {
      show: true,
    };
  },
};
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
</style>
```

过渡类名

在进入/离开的过渡中，会有 6 个 class 切换。

1. `v-enter`：定义进入过渡的开始状态。在元素被插入之前生效，在元素被插入之后的下一帧移除。
2. `v-enter-active`：定义进入过渡生效时的状态。在整个进入过渡的阶段中应用，在元素被插入之前生效，在过渡/动画完成之后移除。这个类可以被用来定义进入过渡的过程时间，延迟和曲线函数。
3. `v-enter-to`：**2.1.8 版及以上**定义进入过渡的结束状态。在元素被插入之后下一帧生效 (与此同时 `v-enter` 被移除)，在过渡/动画完成之后移除。
4. `v-leave`：定义离开过渡的开始状态。在离开过渡被触发时立刻生效，下一帧被移除。
5. `v-leave-active`：定义离开过渡生效时的状态。在整个离开过渡的阶段中应用，在离开过渡被触发时立刻生效，在过渡/动画完成之后移除。这个类可以被用来定义离开过渡的过程时间，延迟和曲线函数。
6. `v-leave-to`：**2.1.8 版及以上**定义离开过渡的结束状态。在离开过渡被触发之后下一帧生效 (与此同时 `v-leave` 被删除)，在过渡/动画完成之后移除。

对于这些在过渡中切换的类名来说，如果你使用一个没有名字的 `<transition>`，则 `v-` 是这些类名的默认前缀。如果你使用了 `<transition name="my-transition">`，那么 `v-enter` 会替换为 `my-transition-enter`。

`v-enter-active` 和 `v-leave-active` 可以控制进入/离开过渡的不同的缓和曲线，在下面章节会有个示例说明。

自定义过渡类名

我们可以通过以下 attribute 来自定义过渡类名：

- `enter-class`
- `enter-active-class`
- `enter-to-class` (2.1.8+)
- `leave-class`
- `leave-active-class`
- `leave-to-class` (2.1.8+)

他们的优先级高于普通的类名，这对于 Vue 的过渡系统和其他第三方 CSS 动画库，如 [Animate.css](https://daneden.github.io/animate.css/)结合使用十分有用。

javascript 钩子

可以在 attribute 中声明 JavaScript 钩子

```HTML
<transition
  v-on:before-enter="beforeEnter"
  v-on:enter="enter"
  v-on:after-enter="afterEnter"
  v-on:enter-cancelled="enterCancelled"

  v-on:before-leave="beforeLeave"
  v-on:leave="leave"
  v-on:after-leave="afterLeave"
  v-on:leave-cancelled="leaveCancelled"
>
  <!-- ... -->
</transition>
```

详细参见：[过渡&动画](https://cn.vuejs.org/v2/guide/transitions.html)

