# MagicalRecord,一个简化CoreData操作的工具库

## 简介

* 项目主页:[https://github.com/magicalpanda/MagicalRecord](https://github.com/magicalpanda/MagicalRecord)
* 实例下载:[https://github.com/ios122/MagicalRecord](https://github.com/ios122/MagicalRecord)

![Awesome](https://github.com/magicalpanda/magicalpanda.github.com/blob/master/images/awesome_logo_small.png?raw=true)

在软件工程中,活动记录模式是一种用于在关系数据库中存储数据的设计模式.这种设计模式最早由Martin Fowler在他的 *Patterns of Enterprise Application Architecture* 一书中命名.这样的一个对象的,接口应该包含插入,更新和删除的方法;再加上与底层数据库几乎直接对应的的属性.

>   活动记录是一种访问数据库中数据的方式.一个数据库的表或者试图被装箱进一个类中;因此,一个对象实例对应表中的一行数据.在创建对象之后,会往表中添加新的一行以保存数据.加载对象时,从数据库中获取信息;当对象更新时,表中对应的行也会被更新.装箱类实现存取方法和分别对应表或视图中每一列的属性.
 
> *- [Wikipedia](https://zh.wikipedia.org/wiki/Active_Record)*

MagicalRecord 受Ruby on Rails活动记录获取方式的便利性影响.项目目标是:

* 清理我的Core Data相关代码
* 支持清晰,简单,一行代码式的查询
* 当需要优化请求时,仍然可以修改 NSFetchRequest.

## 使用 CocoaPods 安装

1. 把下面一行添加到 `Podfile`:

    ````ruby
    pod "MagicalRecord"
    ````
    
2. 在工程目录执行: `pod update` (国内推荐使用 `pod update --verbose --no-repo-update`)
3. 现在你可以添加`#import <MagicalRecord/MagicalRecord.h>`到任意项目源文件中,并开始使用MagicalRecord!

## 定义我们的数据模型

以定义实体 "Person"为例,它有属性age, firstname和lastname.

1. 创建一个新的数据模型,命名为TestModel(File --> New --> File-->Core Data > Data Model)
2. 添加一个新的实体,名为Person(Add Entity)
3. 添加属性age (Integer16), firstname (String)和 lastname (String)
4.创建 NSManagedObject (Editor > Create NSManagedObject Subclass… > Create)子类以更好地管理我们的实体


## Core Data的初始化与清理

如果在创建工程之初勾选了使用Core Data的选项,系统会自动在AppDelegate中生成大量的Core Data初始化与清理代码.但是那些完全各使用一行代码代替,如下:

```obj
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStack];
    // ...
    return YES;
}
 
- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}
```

### 代码解读

首先,在需要使用MagicalRecord的地方,引入头文件:

```objective-c
#import <MagicalRecord/MagicalRecord.h>
```
然后,在你的App代理, `- applicationDidFinishLaunching: withOptions:`方法, 或 `-awakeFromNib` 方法中,使用下面方法中的 **一种** 来初始化 ** MagicalRecord** 类的调用:

```objective-c
+ (void)setupCoreDataStack;
+ (void)setupAutoMigratingCoreDataStack;
+ (void)setupCoreDataStackWithInMemoryStore;
+ (void)setupCoreDataStackWithStoreNamed:(NSString *)storeName;
+ (void)setupCoreDataStackWithAutoMigratingSqliteStoreNamed:(NSString *)storeName;
+ (void)setupCoreDataStackWithStoreAtURL:(NSURL *)storeURL;
+ (void)setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:(NSURL *)storeURL;
```

每一个调用,实例化Core Data栈的某一个部分,并提供这些实例的获取器和设置器方法.这些实例在 MagicalRecord 中均可用,并被识别为 "默认实例".

如果工程有`DEBUG`标记,此时使用默认的SQLite数据存储,不创建新的版本的数据模型而是直接改变数据模型本身的方式,将会删除旧的存储并自动创建一个新的.这会节省大量的时间 - 不再需要在改变数据模型后每次都重新卸载和安装应用! **请确保发布应用时,不开启 `DEBUG` 标记: 不告知用户,直接删除应用的数据,真的很不好!**

在你的应用退出前,你应该调用类方法 `+cleanUp`:

```objective-c
[MagicalRecord cleanUp];
```

这用于使用MagicalRecord后的整理工作:解除我们自定义的错误处理器并把MagicalRecord创建的所有的Core Data 栈设为 nil.

## 开启iCloud 持久化存储

为了更好地使用苹果的iCloud Core Data 同步机制,使用下面初始化方法中的**一种**来替换来替换前面列出的标准初始化化方法:

```objective-c
+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                              localStoreNamed:(NSString *)localStore;

+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                               contentNameKey:(NSString *)contentNameKey
                              localStoreNamed:(NSString *)localStoreName
                      cloudStorePathComponent:(NSString *)pathSubcomponent;

+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                               contentNameKey:(NSString *)contentNameKey
                              localStoreNamed:(NSString *)localStoreName
                      cloudStorePathComponent:(NSString *)pathSubcomponent
                                   completion:(void (^)(void))completion;

+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                              localStoreAtURL:(NSURL *)storeURL;

+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                               contentNameKey:(NSString *)contentNameKey
                              localStoreAtURL:(NSURL *)storeURL
                      cloudStorePathComponent:(NSString *)pathSubcomponent;

+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID
                               contentNameKey:(NSString *)contentNameKey
                              localStoreAtURL:(NSURL *)storeURL
                      cloudStorePathComponent:(NSString *)pathSubcomponent
                                   completion:(void (^)(void))completion;
```

更多细节,请阅读 [Apple's "iCloud Programming Guide for Core Data"](https://developer.apple.com/library/ios/documentation/DataManagement/Conceptual/UsingCoreDataWithiCloudPG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013491).


### 注意

如果你正在管理多重是用iCloud的数据存储,我们建议你使用那些更长的初始化方法,以自定义**contentNameKey**.较短的初始化方法,会基于你应用的 bundle id(`CFBundleIdentifier`),自动生成 **NSPersistentStoreUbiquitousContentNameKey**.

## 操作被管理的对象上下文

对象上下文环境是你操作Core Data内数据的基础,只有正确获取到了上下文环境,才有可能进行相关的读写操作.换句话说,程序的任意位置,只要能正确获取上下文,都能进行Core Data的操作.这也是使用Core Data共享数据的基础之一.相较于传统的方式,各个页面之间只需要与一个透明的上下文环境进行交互,即可进行页面间数据的共享.

下面是一个简单的例子,具体含义下文都会提到:

```objc
    // 获取上下文环境
    NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_context];
    
    // 在当前上下文环境中创建一个新的 Person 对象.
    Person *person  = [Person MR_createEntityInContext:localContext];
    person.firstname = firstname;
    person.lastname  = lastname;
    person.age       = age;
    
    // 保存修改到当前上下文中.
    [localContext MR_saveToPersistentStoreAndWait];
```

### 创建新的对象上下文

许多简单的类方法可以用来帮助你创建一个新的对象上下文:

- `+ [NSManagedObjectContext MR_context]`: 设置默认的上下文为它的父级上下文.并发类型为 **NSPrivateQueueConcurrencyType**.
- `+ [NSManagedObjectContext MR_newMainQueueContext]`: 并发类型为 ** NSMainQueueConcurrencyType**.
- `+ [NSManagedObjectContext MR_newPrivateQueueContext]`: 并发类型为 **NSPrivateQueueConcurrencyType**.
- `+ [NSManagedObjectContext MR_contextWithParent:…]`: 允许自定义父级上下文.并发类型为 **NSPrivateQueueConcurrencyType**.
- `+ [NSManagedObjectContext MR_contextWithStoreCoordinator:…]`:允许自定义持久化存储协调器.并发类型为 **NSPrivateQueueConcurrencyType**.

### 默认上下文

当使用Core Data时,你经常使用的连两类主要对象是: `NSManagedObject`和 `NSManagedObjectContext`.

MagicalRecord 提供了一个简单类方法来获取一个默认的 `NSManagedObjectContext` 对象,这个对象在整个应用全局可用.这个上下文对象,在主线程操作,对于简单的单线程应用来说非常强大.

为了获取默认上下文,调用:

```objective-c
NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
```

这个上下文对象,在MagicalRecord的任何需要使用上下文对象方法中都可以使用,但是并不需要给这些方法显示提供一个指定对象管理上下文对象参数.

如果你想创建一个新的对象管理上下文对象,以用于非主线程,可使用下面的方法:

```objective-c
NSManagedObjectContext *myNewContext = [NSManagedObjectContext MR_context];
```

这将会创建一个新的对象管理上下文,和默认的上下文对象有相同的对象模型和持久化存储;但是在另一个线程中使用时,是线程安全的.它自动设置默认上下文对象为父级上下文.

如果你想要将你的 `myNewContext` 实例作为所有获取请求默认的上下文对象,使用下面的类方法:

```objective-c
[NSManagedObjectContext MR_setDefaultContext:myNewContext];
```

> **注意:** *强烈*  建议默认的上下文对象在主线程使用并发类型为`NSMainQueueConcurrencyType`的对象管理上线文对象创建和设置.

### 在后台线程中执行任务

MagicalRecord 提供方法来设置和在后台线程中使用上下文对象.后台保存操作受UIView的动画回调方法启发,仅有的小小差别:

* 用于更改实体的block将永远不会在主线程执行.
* 在你的block内部提供一个单一的 **NSManagedObjectContext** 上下文对象.

例如,如果我们有一个Person实体对象,并且我们需要设置它的firstName和lastName字段,下面的代码展示了如何使用MagicalRecord来设置一个后台保存的上下文对象:

```objective-c
  // 获取上下文环境
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    
    // 在当前上下文环境中创建一个新的 Person 对象.
    Person *person  = [Person MR_createEntityInContext:defaultContext];
    person.firstname = @"firstname";
    person.lastname  = @"lastname";
    person.age       = @100;
    
    // 保存修改到当前上下文中.
    [defaultContext MR_saveToPersistentStoreAndWait];
    
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        Person *localPerson = [person MR_inContext:localContext];
        localPerson.firstname = @"Yan";
        localPerson.lastname = @"Feng";
    }];
```

在这个方法中,指定的block给你提供了一个合适的上下文对象来执行你的操作,你不需要担心这个上下文对象的初始化来告诉默认上线文它准备好了,并且应当更新,因为变更是在另一个线程执行.

为了在保存block完成时执行某个操作,你可以使用 completion block:

```objective-c
// 获取上下文环境
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    
    // 在当前上下文环境中创建一个新的 Person 对象.
    Person *person  = [Person MR_createEntityInContext:defaultContext];
    person.firstname = @"firstname";
    person.lastname  = @"lastname";
    person.age       = @100;
    
    // 保存修改到当前上下文中.
    [defaultContext MR_saveToPersistentStoreAndWait];
    
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        Person *localPerson = [person MR_inContext:localContext];
        localPerson.firstname = @"Yan";
        localPerson.lastname = @"Feng";
    }  completion:^(BOOL success, NSError *error) {
        
        NSArray * persons = [Person MR_findAll];
        
        [persons enumerateObjectsUsingBlock:^(Person * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"firstname: %@, lastname: %@\n", obj.firstname, obj.lastname);
        }];
        
    }];
```

这个完成的block,在主线程(队列)中调用,所以可以在此block里安全触发UI更新.

## 创建实体对象

为了创建并插入一个新的实体实例到默认上下文对象中,你可以使用:

```objective-c
Person *myPerson = [Person MR_createEntity];
```

创建实体实例,并插入到指定的上下文中:

```objective-c
Person *myPerson = [Person MR_createEntityInContext:otherContext];
```

## 删除实体对象

删除默认上下文中的实体对象:

```objective-c
[myPerson MR_deleteEntity];
```

删除指定上下文中的实体对象:

```objective-c
[myPerson MR_deleteEntityInContext:otherContext];
```

删除默认上下文中的所有实体:

```objective-c
[Person MR_truncateAll];
```

删除指定上下文中的所有实体:

```objective-c
[Person MR_truncateAllInContext:otherContext];
```


## 获取实体对象

### 基础查找

MagicalRecord中的大多数方法返回 `NSArray`结果.

举个例子,如果你有一个名为 *Person* 的实体,和实体 *Department* 关联,你可以从持久化存储中获取所有的 *Person* 实体:

```objective-c
NSArray *people = [Person MR_findAll];
```

可以指定以某个属性排序:

```objective-c
NSArray *peopleSorted = [Person MR_findAllSortedBy:@"LastName"
                                         ascending:YES];
```

可以使用多个属性进行排序:

```objective-c
NSArray *peopleSorted = [Person MR_findAllSortedBy:@"LastName,FirstName"
                                         ascending:YES];
```

当使用多个属性进行排序时,可以单独指定升序或降序.

```objective-c
NSArray *peopleSorted = [Person MR_findAllSortedBy:@"LastName:NO,FirstName"
                                         ascending:YES];

// 或者

NSArray *peopleSorted = [Person MR_findAllSortedBy:@"LastName,FirstName:YES"
                                         ascending:NO];
```

如果你有办法通过某种方式从数据库中获取唯一的一个对象(比如,给对象一个特定的唯一标记),你可以使用下面方法获取某个实体对象:

```objective-c
Person *person = [Person MR_findFirstByAttribute:@"FirstName"
                                       withValue:@"Forrest"];
```

### 高级查找

如果查找条件很复杂,你可以使用正则表达式:

```objective-c
NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"Department IN %@", @[dept1, dept2]];
NSArray *people = [Person MR_findAllWithPredicate:peopleFilter];
```

###返回 一个 NSFetchRequest

```objective-c
NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"Department IN %@", departments];
NSFetchRequest *people = [Person MR_requestAllWithPredicate:peopleFilter];
```
每执行一次,就创建一个这些查询条件对应的 `NSFetchRequest`和 `NSSortDescriptor`.

### 自定义查询请求

```objective-c
NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"Department IN %@", departments];

NSFetchRequest *peopleRequest = [Person MR_requestAllWithPredicate:peopleFilter];
[peopleRequest setReturnsDistinctResults:NO];
[peopleRequest setReturnPropertiesNamed:@[@"FirstName", @"LastName"]];

NSArray *people = [Person MR_executeFetchRequest:peopleRequest];
```

### 获取实体数量

你可以获取持久化存储中指定种类实体的总数量:

```objective-c
NSNumber *count = [Person MR_numberOfEntities];
```

或者,你也可以或者符合指定过滤条件的实体的总数量:

```objective-c
NSNumber *count = [Person MR_numberOfEntitiesWithPredicate:...];
```

有对应的返回`NSUInteger`的方法:

```objective-c
+ (NSUInteger) MR_countOfEntities;
+ (NSUInteger) MR_countOfEntitiesWithContext:(NSManagedObjectContext *)context;
+ (NSUInteger) MR_countOfEntitiesWithPredicate:(NSPredicate *)searchFilter;
+ (NSUInteger) MR_countOfEntitiesWithPredicate:(NSPredicate *)searchFilter
                                     inContext:(NSManagedObjectContext *)context;
```

### 集合操作

```objective-c
NSNumber *totalCalories = [CTFoodDiaryEntry MR_aggregateOperation:@"sum:"
                                                      onAttribute:@"calories"
                                                    withPredicate:predicate];

NSNumber *mostCalories  = [CTFoodDiaryEntry MR_aggregateOperation:@"max:"
                                                      onAttribute:@"calories"
                                                    withPredicate:predicate];

NSArray *caloriesByMonth = [CTFoodDiaryEntry MR_aggregateOperation:@"sum:"
                                                       onAttribute:@"calories"
                                                     withPredicate:predicate
                                                           groupBy:@"month"];
```

### 在指定上下文中查找实体

所有的查找,获取和请求方法,都有一个对应的含有 `inContext:` 参数的方法,来让你指定要进行某种操作的具体上下文环境:

```objective-c
NSArray *peopleFromAnotherContext = [Person MR_findAllInContext:someOtherContext];

Person *personFromContext = [Person MR_findFirstByAttribute:@"lastName"
                                                  withValue:@"Gump"
                                                  inContext:someOtherContext];

NSUInteger count = [Person MR_numberOfEntitiesWithContext:someOtherContext];
```


## 保存实体对象

### 何时应该保存?

通常,你的应用应该在数据变化时,将其保存到持久化存储层中.有些应用选择仅在应用结束时保存,但是在大多数情况下并不需要这样做 - 实际上,**如果你仅在应用退出时保存数据,很有可能会丢失数据**!如果你的应用闪退了,会生什么?用户会丢失所有已经保存的数据 - 这是一种非常糟糕的用户体验,却又很容易避免.

如果你发现保存操作耗费了很长时间,你应该考虑使用一些方式优化:

1. **在后台线程保存**: MagicalRecord 提供了一种简捷的API来改变并立即在后台线程保存数据 - 例如:


	````objective-c
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

		// Do your work to be saved here, against the `localContext` instance
		// Everything you do in this block will occur on a background thread

	} completion:^(BOOL success, NSError *error) {
		[application endBackgroundTask:bgTask];
		bgTask = UIBackgroundTaskInvalid;
	}];
	````

2. **把任务分割成小块的保存任务**: 某些数据量较大的任务,如导入大量的数据,应该被分割成更小块的保存任务.没有统一的标准规定单次保存多少任务最合适,所以你需要使用工具来测试你的应用工的性能以针对自己的应用进行调整.工具可选使用 Apple的 Instruments.


### 处理需要长时间运行的保存任务

当iOS应用退出时,有一个较短的时间来整理和保存数据到磁盘.如果你确定某个保存操作很可能会花费一定时间,最好的方式是请求延长应用的生命周期,比如这样:

````objective-c
UIApplication *application = [UIApplication sharedApplication];

__block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}];

[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

	// 这里有任何保存操作

} completion:^(BOOL success, NSError *error) {
	[application endBackgroundTask:bgTask];
	bgTask = UIBackgroundTaskInvalid;
}];
````

请确定已经仔细 [阅读 `beginBackgroundTaskWithExpirationHandler`相关文档](https://developer.apple.com/library/iOS/documentation/UIKit/Reference/UIApplication_Class/Reference/Reference.html#//apple_ref/occ/instm/UIApplication/beginBackgroundTaskWithExpirationHandler),因为不适当或不必要地延长应用的生命周期,可能会导致应用被App Store拒绝.

## 导入数据

> 我们在持续更新这篇文档-谢谢您的耐心阅读.
> 暂时, 推荐阅读[Importing Data Made Easy](http://www.cimgf.com/2012/05/29/importing-data-made-easy/) ,它发表在 [Cocoa Is My Girlfriend](http://www.cimgf.com/).这篇文档的大部分都是基于Saul的原始文章.
>
> <cite>MagicalRecord 团队</cite>

MagicalRecord 支持从标准的 NSObject 实例对象,如NSArray 和 NSDictionary 直接导入进 Core Data 存储.

使用MagicalRecord从外部数据源导入数据,需要两步:

1. **定义要导入的数据与Core Data存储之间的映射** 使用数据模型(可以少写许多代码!) (it's pretty much codeless!)
2. **执行数据导入操作**


### 定义导入

外部数据源的数据,在质量和结构上,可能是很混乱的,所以我们需要尽可能使MagicalRecord的导入过程更灵活.

**MagicalRecord 可以从符合键值编码(KVC)的对象中导入数据**. 我们经常见到人们导入NSArray`和 `NSDictionary`实例的对象,但是对于所有符合键值编码(KVC)的对象都是支持的.

MagicalRecord 使用 Xcode的数据模型工具(点击工程中TestModel.xcdatamodeld即可出现)的"**User Info**"的值来配置导入选项与可能的映射关系,而不用写任何代码.(下图中的 mappedKeyName为系统保留字段,用来指定要映射的key,具体细节往下阅读即可)

<p align="center">
<img src="http://cl.ly/image/1e333E3W2Y3E/datamodeller_userinfogroup.png" alt="Xcode's 'User Info' group in the data modeller" width="324" height="374" style="margin: 0 auto;" />
</p>

> **供参考**: 用户的模型信息中的键和值在一个字典中存储,每个实体,属性,和关系都关联这样一个字典.这个字典可以通过`NSEntityDescription`对象的`userInfo`方法取出.

Xcode的数据模型工具使你可以通过 Data Model Inspecto的"User Info"分组来存取这个字典.当编辑一个数据模型时,你可以使用Xcode菜单打开这个inspector -  **View > Utilities > Show Data Model Inspector**, 或者使用快捷键 <kbd>⌥⌘3</kbd>.

默认地, MagicalRecord 会自动尝试使用要导入的数据中的键匹配属性和关系名. **如果一个CoreData模型中的属性或关系名与要导入的数据中的某个键匹配,那你不需要做任何事 - 键对应的值会自动导入.**

例如,如果一个实体有一个属性名为 `firstName`, MagicalRecord 会假定要导入的数据中也有一个名为 `firstName`的键 - 如果确实存在,你的实体的 `firstName`属性会被设置为你要导入的数据中的 `firstName`键对应的值.

往往,要导入的数据中的键和结构和你的实体属性与关系不匹配.在这种情况下,你需要告诉 MagicalRecord 如何映射你要导入的数据的键到你的CoreData模型中匹配的属性或关系.

我们在Core Data中接触的三类最重要的对象-实体,属性和属性,都有需要在用户info键组配置的选项:

### 属性

|键 |类型 |目的 |
|-----|------|---------|
| **attributeValueClassName** | String |待定 |
| **dateFormat** | String |待定. 默认 `yyyy-MM-dd'T'HH:mm:ssz`. |
| **mappedKeyName**       | String | 指定对应的要导入的数据中的keypath.支持keypath,以 `.`分割,如 `location.latitude`. |
| **mappedKeyName.[0-9]** | String | 指定备用的keypath,在**mappedKeyName**指定的keypath不存在时使用.规则同上. |
| **useDefaultValueWhenNotPresent** | Boolean | 为true时,如果要导入的数据没有对应的键,就使用此属性预设的默认值. |

### 实体

|键 |值 |目的 |
|-----|------|---------|
| **relatedByAttribute**  | String | 指定用来链接两个实体的关系的目标实体中的属性. |

### 关系

| 键 | 值 |目的 |
|-----|------|---------|
| **mappedKeyName**       | String | 指定对应的要导入的数据中的keypath.支持keypath,以 `.`分割,如 `location.latitude`. |
| **mappedKeyName.[0-9]** | String | 指定备用的keypath,在**mappedKeyName**指定的keypath不存在时使用.规则同上. |
| **relatedByAttribute**  | String | 指定用来链接两个实体的关系的目标实体中的属性. |
| **type** | String | 待定 |


### 导入对象

使用MagicalRecord导入数据到持久化存储前,你需要知道: 你要导入的数据格式,以及如何导入.

MagicalRecord的导入数据的方法最基础的方法是: 你知道数据应该要导入的实体,然后你可以写一行简单的代码来标记数据要导入的实体.有许多方式来自定义导入的过程.

从对象自动创建一个实体实例,你可以使用更简洁的方式:

```objective-c
NSDictionary *contactInfo = // JSON解析器或其他数据源返回的结果.

Person *importedPerson = [Person MR_importFromObject:contactInfo];
```

你也可以把它分为两步:

```objective-c
NSDictionary *contactInfo = // JSON解析器或其他数据源返回的结果.
Person *person = [Person MR_createEntity]; // 这里不是必须为一个新创建的实体.
[person MR_importValuesForKeysWithObject:contactInfo];
```

分为两步的写法,在你尝试使用新的属性更新已有实体时,会很有用.

`+MR_importFromObject:` 会尝试基于配置的查询值(参见_relatedByAttribute_ 和 _attributeNameID_)来寻找一个已经存在的实体.它遵循Cocoa内置的导入相关的编程范例需要的键值对,和导入数据的安全方式.

`+MR_importFromObject:`类方法封装了前面的使用`-MR_importValuesForKeysWithObject:`实例方法创建新对象的逻辑,并且会返回一个用给定数据填充的新创建的对象.

必须要注意的是,这两种方式都是同步的.当有些导入操作会比较耗费时间时,后台执行 **所有的导入操作**仍然是非常明智的,以免对用户交互产生不良影响.前面已经讨论过, MagicalRecord 提供了便利的API来让使用后台线程更加易于控制:

```objective-c
[MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *)localContext {
  Person *importedPerson = [Person MR_importFromObject:personRecord inContext:localContext];
}];
```

### 导入数组

由一个JSON数组提供的一组数据或者正在导入大量的单一类型数据的情况,很常见.导入这样的一组数据的具体实现细节,由`+MR_importFromArray:`类方法中能找到.

```objective-c
NSArray *arrayOfPeopleData = /// result from JSON parser
NSArray *people = [Person MR_importFromArray:arrayOfPeopleData];
```

这个方法,和 `+MR_importFromObject:`一样,也是同步的,所以应该使用前面提到的后台执行block的方式来导入数据.

### 最佳实践

如果你要导入的数据,可能有少许差异甚至错乱,那就请继续往下读.下面列出MagicalRecord的其他的一些特性来帮助你处理一些常见的情况.

#### 在导入时处理不良数据

API经常返回格式或或值不一致的数据.最好的方式是在你的实体对象上,使用导入的类目方法来处理.有三个方法可用:

方法                         |目的
--------------------------------|---------
`- (BOOL) shouldImport;`        | 在数据导入前调用.返回 `NO`,可以终止某条特定数据的导入.
`- (void) willImport:(id)data;` | 数据导入前调用.
`- (void) didImport:(id)data;`  | 数据导入后调用. 

通常,如果你数据是损坏的,你可能需要在导入数据前尝试修复它.

一个常见的情况是,要导入的 JSON数据中,数字字符串很容易被误处理为一个真实的数字.如果你想要确保某个值是以字符串形式导入,你可以这样做:

```obj-c

@interface MyGreatEntity

@property(readwrite, nonatomic, copy) NSString *identifier;

@end

@implementation MyGreatEntity

@dynamic identifier;

- (void)didImport:(id)data
{
  if (NO == [data isKindOfClass:[NSDictionary class]]) {
    return;
  }

  NSDictionary *dataDictionary = (NSDictionary *)data;

  id identifierValue = dataDictionary[@"my_identifier"];

  if ([identifierValue isKindOfClass:[NSNumber class]]) {
    NSNumber *numberValue = (NSNumber *)identifierValue;

    self.identifier = [numberValue stringValue];
  }
}

@end
```

#### 在导入更新时,删除本地记录.

有时,你可能想要在导入数据时,不仅更新数据,还要删除本地记录中不存在于远程数据库中的数据.为了实现这个效果,根据`relatedByAttribute` (下面的例子中是 `id`)获取本地所有不在更新中的实体, 并在导入新的数据前直接移除它们.

```objective-c
NSArray *arrayOfPeopleData = /// result from JSON parser
NSArray *people = [Person MR_importFromArray:arrayOfPeopleData];
NSArray *idList = [arrayOfPeopleData valueForKey:@"id"];
NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(id IN %@)", idList];
[Person MR_deleteAllMatchingPredicate:predicate];
```

如果你还想在更新时在移除所有已移除的记录的相关对象,你可以使用与上面相似的逻辑,只是要在`Person` 的`willImport:` 方法中实现.

```objective-c

@implementation Person

-(void)willImport:(id)data {
    NSArray *idList = [data[@"posts"] valueForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(id IN %@) AND person.id == %@", idList, self.id];
    [Post MR_deleteAllMatchingPredicate:predicate];
}
```

来源: [http://stackoverflow.com/a/24252825/401092](http://stackoverflow.com/a/24252825/401092)

## 日志

MagicalRecord 内部记录大多数自身与Core Data 的交互.当在获取或保存数据发生错误时,这些错误会被捕捉并(如果你启用了日志)输出到控制台.

默认地,在debug构建时,输出调试信息 (**MagicalRecordLoggingLevelDebug**),在release构建时,输出错误信息.

日志可以通过调用`[MagicalRecord setLoggingLevel:];`来配置.预置的几个错误日志级别:

- **MagicalRecordLogLevelOff**: 不输出任何信息.
- **MagicalRecordLoggingLevelError**: 输出错误信息.
- **MagicalRecordLoggingLevelWarn**: 输出警告和错误
- **MagicalRecordLoggingLevelInfo**: 输出信息,警告和错误.
- **MagicalRecordLoggingLevelDebug**: 输出所有的调试信息,信息,警告和错误.
- **MagicalRecordLoggingLevelVerbose**:输出冗长的诊断信息,信息, 警告和错误

日志级别,默认是 `MagicalRecordLoggingLevelWarn`.

### CocoaLumberjack

如果CocoaLumberjack可用, MagicalRecord会自动把日志交由 [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack).所有你需要做的就是保证CocoaLumberjack 在 MagicalRecord之前导入,像这样:

```objective-c

// Objective-C
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <MagicalRecord/MagicalRecord.h>

```

### 完全禁用日志输出.

对大多数人来说,都很没必要.把日志级别设为**MagicalRecordLogLevelOff**将不会有日志被打印.

及时你把日志级别设为 `MagicalRecordLogLevelOff`, 一个快速检查的逻辑也是会别执行当有调用日志输出时.如果你想绝对禁用日志,你需要在编译MagicalRecord时定义以下宏:

```objective-c
#define MR_LOGGING_DISABLED 1
```

注意,在仅在你把MagicalRecord的源文件添加到你自己的工程中时可用.你也可以把`-DMR_LOGGING_DISABLED=1`添加到你工程的`OTHER_CFLAGS`来得到相同的作用.


## 其他资源

下面的文章进一步讨论了MagicalRecord的安装和使用的各个方面细节(可能需要翻墙):

* [How to make Programming with Core Data Pleasant](http://yannickloriot.com/2012/03/magicalrecord-how-to-make-programming-with-core-data-pleasant/)
* [Super Happy Easy Fetching in Core Data](http://www.cimgf.com/2011/03/13/super-happy-easy-fetching-in-core-data/)
* [Core Data and Threads, without the Headache](http://www.cimgf.com/2011/05/04/core-data-and-threads-without-the-headache/)
* [Unit Testing with Core Data](http://www.cimgf.com/2012/05/15/unit-testing-with-core-data/)

---
注: 文章由我们 iOS122(http://www.ios122.com)的小伙伴 ```@颜风``` 整理,喜欢就一起参与: [iOS122 任务池](http://www.ios122.com/任务池/)