## 安装或更新插件

```fish
# 安装插件
fisher install (string trim < ~/.config/fish/fish_plugins | string match -rv '^(#|$)')

# 更新插件
fisher update (string trim < ~/.config/fish/fish_plugins | string match -rv '^(#|$)')
```
