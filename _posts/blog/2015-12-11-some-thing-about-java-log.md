---
layout:      post
title:       Java日志那点儿事儿
category:    blog
description: 日志这东西在语言里算基础组件了吧，可惜Java界第三方框架向来比原生组件好用也是事实，缺点是框架太多混战江湖，今天我们就理一理这些日志框架
---

##前言

日志这东西在语言里算基础组件了吧，可惜Java界第三方框架向来比原生组件好用也是事实，缺点是框架太多混战江湖，今天我们就理一理这些日志框架。Java的日志框架分为门面（Facade），或者叫通用日志接口，还有日志实现。日志接口不用说，就是定下的日志方法规范，需要具体日志组件去实现的（为啥Sun当年没有定义这东西，看看JPA、JDBC、JMS这些规范定义的多好，或者定义了被抛弃了？）。日志实现就是具体的日志组件了，可以实现日志打印到控制台、文件、数据库等等。下面咱们就具体说说这些东西。

## Java日志框架分类

### 日志门面（Facade）
- #### Slf4j
全称Simple Logging Facade for JAVA，真正的日志门面，只提供接口方法，当配合特定的日志实现时，需要引入相应的桥接包
- #### Common-logging
Apache提供的一个通用的日志接口，common-logging会通过动态查找的机制，在程序运行时自动找出真正使用的日志库，自己也自带一个功能很弱的日志实现。

#### 差别：

1. Common-logging动态查找日志实现（程序运行时找出日志实现），Slf4j则是静态绑定（编译时找到实现），动态绑定因为依赖ClassLoader寻找和载入日志实现，因此类似于OSGI那种使用独立ClassLoader就会造成无法使用的情况。（呵呵，我一个插件用一个日志框架不行啊，土豪多任性，不过说实话，没用过OSGI，这个我还真没有概念）
2. Slf4j支持参数化的log字符串，避免了之前为了减少字符串拼接的性能损耗而不得不写的if(logger.isDebugEnable())，现在你可以直接写：logger.debug(“current user is: {}”, user)。

### 日志实现
- #### Log4j
Log4j可能是Java世界里最出名的日志框架了，支持各种目的地各种级别的日志输出，从我刚接触日志就知道这个框架（呵呵，我一直不知道还有JDK Logging这个东西）。最近（也不近了……）Log4j2发布正式版了，没看到谁用，听说也很不错。

- #### LogBack
Log4j作者的又一力作（听说是受不了收费文档搞了个开源的，不需要桥接包完美适配Slf4j），个人感觉迄今为止最棒的日志框架了，一直都在用，配置文件够简洁，性能足够好（估计是看自己的Log4j代码差劲了，更新不能解决问题，直接重构了）。

- JDK Logging
从JDK1.4开始引入，不得不说，你去Google下这个JDK自带的日志组件，并不如Log4j和LogBack之类好用，木有配置文件，日志级别不好理解，想顺心的用估计还得自己封装下，总之大家已经被Log4j惯坏了，JDK的设计并不能被大家认同，唯一的优点我想就是不用引入新额jar包了。

### 为什么会有门面
看了以上介绍，如果你不是混迹（深陷）Java多年的老手，估计会蒙圈儿了吧，那你肯定会问，要门面干嘛。有了手机就有手机壳、手机膜，框架也一样，门面的作用更多的还是三个字：解耦合。说白了，加入一个项目用了一个日志框架，想换咋整啊？那就一行一行的找日志改呗，想想都是噩梦。于是，门面出来了，门面说啦， 你用我的格式写日志，把日志想写哪儿写哪儿，例如Slf4j-api加上后，想换日志框架，直接把桥接包一换就行。方便极了。

说实话，现在Slf4j基本可以是Java日志的一个标准了，按照它写基本可以实现所有日志实现通吃，但是就有人不服，还写了门面的门面（没错，这个人就是我）。

## 门面的门面
如果你看过Netty的源码，推荐你看下io.netty.util.internal.logging这个包里内容，会发现Netty又对日志封装了一层，于是灵感来源于此，我也对各大日志框架和门面做了封装。

### Hutool-log模块
无论是Netty的日志模块还是我的Hutool-log模块，思想类似于Common Logging，做动态日志实现查找，然后找到相应的日志实现来写入日志，核心代码如下：

```Java
/**

 * 决定日志实现

 * @return 日志实现类

 */
public static Class<? extends AbstractLog> detectLog(){
	List<Class<? extends AbstractLog>> logClassList = Arrays.asList(
			Slf4jLog.class,
			Log4jLog.class, 
			Log4j2Log.class, 
			ApacheCommonsLog.class, 
			JdkLog.class
	);
	
	for (Class<? extends AbstractLog> clazz : logClassList) {
		try {
			clazz.getConstructor(Class.class).newInstance(LogFactory.class).info("Use Log Framework: [{}]", clazz.getSimpleName());
			return clazz;
		} catch (Error | Exception e) {
			continue;
		}
	}
	return JdkLog.class;
}
```

[详细代码可以看这里](https://github.com/looly/hutool/blob/master/src/main/java/com/xiaoleilu/hutool/log/LogFactory.java)

说白了非常简单，按顺序实例化相应的日志实现，如果实例化失败（一般是ClassNotFoundException），说明jar不存在，那实例化下一个，通过不停的尝试，最终如果没有引入日志框架，那使用JDK Logging（这个肯定会有的），当然这种方式也和Common-logging存在类似问题，不过不用到跨ClassLoader还是很好用的。

对于JDK Logging，我也做了一些适配，使之可以与Slf4j的日志级别做对应，这样就将各个日志框架差异化降到最小。另一方面，如果你看过我的[这篇日志](http://my.oschina.net/looly/blog/173576)，那你一定了解了我的类名自动识别功能，这样大家在复制类名的时候，就不用修改日志的那一行代码了，在所有类中，日志的初始化只有这一句：

```Java
Log log = LogFactory.get();
```

是不是简洁简洁又简洁？实现方式也很简单：

```Java
/**
 * @return 获得调用者的日志
 */
public static Log get() {
	return getLog(new Exception().getStackTrace()[1].getClassName());
}
```

通过堆栈引用获得当前类名。

作为一个强迫症患者，日志接口我也会定义的非常处女座：

```Java
/**
 * 日志统一接口
 * 
 * @author Looly
 *
 */
public interface Log extends TraceLog, DebugLog, InfoLog, WarnLog, ErrorLog
```

这样就实现了单一使用，各个日志框架灵活引用的作用了。好了，今天就到这里了，有问题或者吐槽都已给我留言~~