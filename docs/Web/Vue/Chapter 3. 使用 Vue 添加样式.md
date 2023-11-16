# Chapter 3. 使用 Vue 添加样式

Vue提供了几种方式来为网站或是应用添加样式。`v-bind:class` 和 `v-bind:style` 两者都有专门的功能，帮助你通过数据设置class属性和内联样式。当结合vue-loader使用组件时，可以使用scoped CSS来添加样式，并且只在该CSS所在的组件中有效

### class 绑定

通常使用 v-bind 来绑定 class 属性，从而根据数据的变化添加或删除类名。

如果传递一个数组给v-bind:class，数组中的类名将会被拼接到一起

也可以在数组语法中使用对象语法

如下例中，只有当 hasError 为 true 时才会添加error 类

```HTML
<class-and-style 
	v-bind:class="[actived, background, {error: hasError}]">
</class-and-style>
```

### 内联样式绑定

`v-bind:style` 的对象语法十分直观——看着非常像 CSS，但其实是一个 JavaScript 对象

```HTML
<div v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }"></div>
```

也可以直接绑定一个样式对象，这样会让模板更清晰，

在data 中定义一个样式对象

```JavaScript
data(){
	return {
		styleObject: {
			color: 'red',	
		}
	}
}
```

```HTML
<div v-bind:style="styleObject"></div>
```

`v-bind:style` 的数组语法可以将多个样式对象应用到同一个元素上

```HTML
<div v-bind:style="[baseStyles, overridingStyles]"></div>
```

当 `v-bind:style` 使用需要添加[浏览器引擎前缀](https://developer.mozilla.org/zh-CN/docs/Glossary/Vendor_Prefix)的 CSS property 时，如 `transform`，Vue.js 会自动侦测并添加相应的前缀。

多重值

从 2.3.0 起你可以为 `style` 绑定中的 property 提供一个包含多个值的数组，常用于提供多个带前缀的值，例如：

```HTML
<div :style="{ display: ['-webkit-box', '-ms-flexbox', 'flex'] }"></div>
```

### 用 vue-loader 实现 scoped CSS

与JavaScript不同，组件中的CSS不仅会影响自身，还会影响到页面上所有的HTML元素

Vue 提供了一种为组件 css 添加作用域的方法，将组件中的 `<style></style>` 添加 scoped 属性 `<style scoped></style>` 可以将 组件中的 css 限制为只在该组件中有效

添加 scoped 属性后，输出的 HTML 会为组件中每个 HTML 标签添加一个唯一的 data-v-**** 属性，同时也将其添加到CSS选择器中来保证 CSS 只对组件中的 HTML 有效。

### 用 vue-loader 实现 CSS Modules

作为scoped CSS的替代方案，可以用vue-loader实现CSS Modules

将组件中的 `<style></style>` 添加 module 属性 `<style module></style>` 并通过 $style.className 来引用定义好的类

### 预处理器

可以设置vue-loader来让预处理器处理CSS、JavaScript和HTML。假设想要使用SCSS而不是CSS，以利用诸如嵌套和变量这样的特性。可以通过两个步骤来实现：首先通过npm安装sass-loader和node-sass，然后在style标签上添加lang="scss"

