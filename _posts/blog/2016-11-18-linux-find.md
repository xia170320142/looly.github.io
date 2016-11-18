---
layout:      post
title:       Linux学习笔记之find
category:    blog
description: linux find -mtime -ctime -atime解释，+n -n n解释
---

## Linux学习笔记之find

### 1、查找指定时间的内容
```bash
find . -atime    #access time，文件被读取或者执行的时间
find . -ctime    #change time文件状态改变时间
find . -mtime    #modify time，指文件内容被修改的时间
```

### 2、查找指定时间
```bash
find . -mtime +n   #最后一次修改发生在n+1天以前，距离当前时间为(n+1)*24小时或者更早
find . -mtime -n   #最后一次修改发生在n天以内，距离当前时间为n*24小时以内
find . -mtime n    #最后一次修改发生在距离当前时间n*24小时至(n+1)*24 小时
```

### 3、例子

#### (1)删除指定目录下一天前修改的文件
```bash
#!/bin/bash
find [path]/* -maxdepth 0  -mtime +0 -exec rm -f {} \;
```
其中：
- path: 被删除的文件所在目录

- -maxdepth 0: 最大深度0，只删除当前目录下

- -mtime +0: 一天前的文件

- rm -f {} \; 只删除文件，不提示，如果删除目录使用 rm -rf {} \;1. - 这里是列表文本