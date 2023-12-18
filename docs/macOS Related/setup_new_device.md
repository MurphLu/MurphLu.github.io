### command line tools

xcode-select --install

### 显示隐藏文件

```
defaults write com.apple.finder AppleShowAllFiles -bool true
killall finder
```

### brew 包管理工具

`sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### zsh 

`sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

### shell correct

`brew install thefuck`

### ruby version manager, 

> you can install and manage ruby env with this tools
> macOS build-in ruby may not proide some of the header files, 
> which will cause some of the gem lib such as: cocapods fastlane fail install

`brew install rbenv`

> add eval "$(rbenv init -)" into shell config file like: ".bash_profile", ".zshrc" etc.

`rbenv install 2.7.8`
`rbenv global 2.7.8`

### nvm node version manager

`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash`

`nvm install 12/14/16`

### a simple http-server，

you can use it to start up a simple http server (transform files in interal network or something else)

`npm install http-server -g`

### 腾讯垃圾清理工具

https://lemon.qq.com

### go2shell，a tool can add to finder tool bar

> which can start a new terminal in current directory
https://zipzapmac.com/go2shell

### swich default shell such as: sh, zsh etc.

`chsh`
