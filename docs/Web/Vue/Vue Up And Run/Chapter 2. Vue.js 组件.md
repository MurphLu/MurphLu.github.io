# Chapter 2. Vue.js 组件

组件是一段独立的、代表了页面的一个部分的代码片段。它拥有自己的数据、JavaScript脚本，以及样式标签。组件可以包含其他的组件，并且它们之间可以相互通信。组件可以是按钮或者图标这样很小的元素，也可以是一个更大的元素，比如在整个网站或者整个页面上重复使用的表单

组件是独立的，可以确保组件中的代码不会影响任何其他组件或产生任何副作用

定义一个简单的组件，并通过 components 配置对象将其传入 app

```HTML
<div id='app'>
	<custom-button></custom-button>
</div>
<script>
	const CustomButton = {
		template: '<button>自定义按钮</button>'
	};
	new Vue({
		el: '#app',
		components: {
			CustomButton
		}
	})
</script>
```

也可以通过 `Vue.component()` 来注册一个全局组件，这样就可以直接在任意模板中使用这个组件了，并不需要在 components 配置对象中添加该组件

```HTML
Vue.component('custom-button', {
	template: '<button>自定义按钮</button>'
})
```

### 数据、方法和计算属性

每个组件都可以拥有自己的数据、方法和计算属性，以及前面章节中出现过的属性

组件与 Vue 实例之间的一个差别：Vue 实例中 data 属性是一个对象，但是组件中的 data 属性是一个函数，因为组件可以在一个页面上被多次引用，如果共享一个 data 对象的话那将会是灾难（因为同一个组件的每个实例的data属性是同一个对象的引用，当该组件的某个实例修改了自身的data属性，相当于所有实例的data属性都被修改了），所以组件的data属性应该是一个函数，在组件初始化时Vue会调用这个函数来生成data对象

### 传递数据

可以使用 props 属性来传递数据

Props是通过HTML属性传入组件的（比如示例中的color="red"）；之后在组件内部，props属性的值表示可以传入组件的属性的名称

prop 验证

除了可以传递一个的简单数组，来表明组件可以接收的属性的名称，也可以传递一个对象，来描述属性的信息，比如它的类型、是否必须、默认值以及用于高级验证的自定义验证函数

props 的大小写

在HTML中通过kebab（my-prop=‘’）形式指定的属性，会在组件内部自动转换为camel（myProp）形式

响应式

对于data对象、方法还有计算属性，当它们的值发生变化时，模板也会更新；同样，props也是这样的。在父级实例中设定prop的值时，可以使用v-bind指令将该prop与某个值绑定。那么无论何时只要这个值发生变化，在组件内任何使用该prop的地方都会更新

如果 prop 的值类型不是字符串的话，那么必须使用 v-bind 指令，否则会抛出警告

这是因为传递给attr的是一个字符串，而不是数字。如果要传入一个数字，就要使用v-bind指令，它会把传入的值当作表达式求值，然后再传递给prop

```HTML
<template>
  <div>propsTest: {{ numberProp }}</div>
</template>

<script>
export default {
  props: {
    numberProp: {
      type: Number,
      required: true,
    },
	stringProp: {
      type: String,
      required: true
   	}
  },
};
</script>
```

```HTML
<PropTest v-bind:number-prop='10' stringProp='10a'/>
```

### 数据流和.sync修饰符

数据通过prop从父级组件传递到子组件中，当父级组件中的数据更新时，传递给子组件的prop也会更新。但是你不可以在子组件中修改prop

如果想要使用双向绑定，可以使用一个修饰符来实现：.sync修饰符。它只是一个语法糖

```HTML
<PropTest :number-prop.sync='numberToDisplay' stringProp='10a'/>
```

```HTML
<PropTest 
	:number-prop='numberToDisplay'
	@update:number-prop='numberToDisplay'
	stringProp='10a'/>
```

如果想要更改父级组件的值，则需要触发 update:number-prop 事件

```HTML
<template>
  <div>
    <p>propsTest: {{ numberProp }}</p>
    <button @click="updateNumber">{{ numberSync }}</button>
  </div>
  
</template>

<script>
export default {
  props: {
    numberProp: {
      type: Number,
      required: true,
    },
    stringProp: {
      type: String,
      required: true
    },
    numberSync: {
      type: Number,
      required: true,
    }
  },
  methods: {
	// 触发父级组件 update:number-sync 的执行
    updateNumber(){
      this.$emit('update:number-sync', 4)
    }
  }
};
</script>
```

```HTML
<PropTest v-bind:number-prop='10' stringProp='10a' :number-sync.sync="number1"/>
```

*::Warning：如果父级组件与子组件都对同一个值的更新做出反应，并且在处理更新的过程中再次改变这个值，这会让你的应用程序出现问题。::*

如果仅仅想要更新从prop传入的值，而不关心父级组件的值的更新，你可以在一开始的data函数中通过this来引用prop的值，将它复制到data对象中，并为 prop 添加一个侦听器，当prop变化时将新值拷贝到data 对象中

### 自定义输入组件与 v-model

与.sync修饰符相似，可以在组件上使用v-model指令来创建自定义输入组件

```HTML
<input-username
	v-model="username" />
```

等效于：

```HTML
<input-username
	:value="username"
	@input="value=>username=value" />
```

所以，创建inputUsername 组件，我们需要它做两件事：首先，需要通过value 属性获取初始值，然后无论何时只要value值发生变化，它必须触发一个input 事件

### 使用插槽（slot）将内容传递给组件

除了将数据作为prop 传入到组件中，Vue也支持传入HTML。

```HTML
<template>
  <div>
	<!-- 如果不传值，则显示默认内容 -->
    <slot>这是默认内容</slot>
  </div>
</template>
```

```HTML
<!-- 如果传值，则会用传入值替换掉默认值 -->
<slot-test>淦</slot-test>
```

### 具名插槽

具名插槽允许你在同一组件中拥有多个插槽

```HTML
<template>
  <div>
    <header>
      <slot name="header"></slot>
    </header>
    <main>
      <slot></slot>
    </main>
  </div>
</template>
```

使用方法

```HTML
<slot-test>
    <h2 slot="header">这是header</h2>
    <p>淦</p>
</slot-test>
```

上面例子中的 h2则会在 name=header的slot 的位置输出，二其他内容则会输出在slot位置

### 作用域插槽

可以将数据传回slot组件，使父组件中的元素可以访问子组件中的数据

```HTML
<template>
  <div class="user">
    <slot :user="user"></slot>
  </div>
</template>
```

```HTML
<slot-test v-slot="user">    
  <p>淦</p>
  <p v-if="user">用户名：{{ user }}</p>
</slot-test>
```

自定义事件

在 component中触发调用 `this.$emit(‘event’)`

使用这个component时 `<my-component v-on:event=“”></my-component>`

参见 [自定义事件](https://cn.vuejs.org/v2/guide/components-custom-events.html)

### Mixin

Mixin 是一种代码组织方式，可以在多个组件间横向复用代码。当组件间包含比较多的共同逻辑代码，那么有三种方式来处理这种情况：为所有组件编写重复代码；将共同代码分离到多个函数中，并存储到util 文件里；使用 mixin，当然，mixin 更符合Vue 习惯的处理方式

只要将 mixin 对象添加到组件中，那么该组件就可以获取到存储在 mixin 对象中的任何东西

mixin 对象和 组件的合并

对于生命周期的钩子，Vue 会将 mixin 和组件中的实现添加到一个数组中，并全部执行

但是对于重复的方法、计算属性或者其他组件自有的非生命周期钩子的属性，那么组件中的属性会覆盖掉 mixin 对象中相同的属性

### vue-loader 和 .vue 文件

vue-loader 提供了一种方法，可以再在 .vue 文件中编写基于单个文件的组件

```HTML
<template>
</template>
<script>
export default{
	
}
</script>
<style>
</style>
```

经过webpack 和 vue-loader 处理之后，可以正常使用组件，在父组件中通过 import 的方式引入子组件

### 非 prop 属性

如果某个组件设置的属性并不是用作prop，那么该属性会被添加到 HTML 跟元素上，比如一些默认的 HTML attribute  class，style 等

如果组件和组件的根元素设置相同的属性，那么如果该属性为 class 或者 style，那么输出结果中将会合并组件和组件跟元素设置的属性值，如果是其他属性，那么组件中设置的属性值会直接替换掉组件根元素的属性值

### 组件和 v-for 指令

当使用v-for指令遍历一个数组或是对象，并且给定的数组或对象改变时，Vue不会再重复生成所有的元素，而是智能地找到需要更改的元素，并且只更改这些元素。

可是，如果你在数组的中间删除或是添加一个元素，Vue不会知道该元素对应的是页面上哪一个元素，它会更新从删除或是添加元素的位置到列表结尾之间的每一个元素。这种操作对于复杂结构来说，显然是不合适的

使用v-for指令时可以设置一个key属性，通过它可以告诉Vue数组中的每个元素应该与页面上哪个元素相关联，从而删除正确的元素

使用数组下标作为key 值也是不明智的，虽然Vue不会再发出警告，一个并非你期望的元素将被删除

