---
layout:      post
title:       Python学习笔记-面向对象篇
category:    blog
description: 学习来源：http://python.xiaoleilu.com/ http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000
---

![cover](http://img.hb.aicdn.com/1d5ebdc0c15cdbae263160f760f137ba1188e29922afa-pWXF70)

## 定义

```python
#创建类
class Student1:
    pass

#创建类，继承自object类
class Student1(object):
    pass

#带构造方法的类以及对象方法调用
class Student2(object):

    def __init__(self, name, score):
        self.name = name
        self.score = score

    def print_score(self):
        print('%s: %s' % (self.name, self.score))
```

##实例化和调用

```python
#实例化类
>>> bart = Student1()
>>> bart
<__main__.Student object at 0x10a67a590>
>>> Student1
<class '__main__.Student'>

>>> bart = Student2('Bart Simpson', 59)
>>> bart.print_score()
Bart Simpson: 59

#绑定属性
>>> bart.name = 'Bart Simpson'
>>> bart.name
'Bart Simpson'
```

## 访问限制
1. 双下划线`__`： 私有变量（解释器把双下划线改成了单下划线，依旧可以通过单下划线访问）
2. 单下划线`_`： 可以被外部访问，但约定俗称不要访问
3. 双下划线包围`__XXX__`： 特殊变量，可以访问

## 继承

```python
#父类、基类或者超类
class Animal(object):
    def run(self):
        print('Animal is running...')

#子类
class Dog(Animal):
    pass

class Cat(Animal):
    pass
```

## 多态
在继承关系中，如果一个实例的数据类型是某个子类，那它的数据类型也可以被看做是父类。但是，反过来就不行。

## 对象类型
1. `type()`: 判断对象类型
2. `isinstance()`：对象是否是某种类型
3. `dir()`：对象的所有属性和方法
4. `hasattr(obj, 'x')`：有属性'x'吗？
5. `setattr(obj, 'y', 19)`：设置一个属性'y'
6. `getattr(obj, 'y')`：获取属性'y'，属性不存在，抛出`AttributeError`

## 实例属性和类属性
```python
class Student(object):
    #类属性
    name = 'Student'

    #实例属性
    def __init__(self, name):
        self.name = name
```