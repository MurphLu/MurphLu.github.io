## Category

通过 runtime 动态将 Category 方法合并到类对象/元类对象中

分类的底层结构
``` C++
struct _category_t {
	const char *name; // 类名
	struct _class_t *cls; // 类
	const struct _method_list_t *instance_methods; // 实例方法
	const struct _method_list_t *class_methods; // 类方法
	const struct _protocol_list_t *protocols; // 协议
	const struct _prop_list_t *properties; // 属性
};
```

编译完之后，分类的信息全部存放在 `_category_t` 结构中，而不是合并到对应的类中

比如下面的分类：

```Objective-C
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN
@protocol P
-(void)smile;
@end

@interface Person (Action) <P>
@property (nonatomic, assign) int a;

-(void) run;
@end

NS_ASSUME_NONNULL_END

#import "Person+Action.h"
@implementation Person (Action)
@dynamic a;

-(void) run {
    NSLog(@"running.....");
}
-(void) eat {
    NSLog(@"eating.....");
}
+(void)sleep {
    NSLog(@"sleepping.....");
}

- (void)smile {
    NSLog(@"ha");
}

@end
```

编译成 C++ 代码之后为

```C++
static struct _category_t _OBJC_$_CATEGORY_Person_$_Action __attribute__ ((used, section ("__DATA,__objc_const"))) = 
{
	"Person",
	0, // &OBJC_CLASS_$_Person,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Action,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Action,
	(const struct _protocol_list_t *)&_OBJC_CATEGORY_PROTOCOLS_$_Person_$_Action,
	(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Person_$_Action,
};
```

分类在 runtime 中的加载

- objc-os.mm

```C++
/***********************************************************************
* _objc_init
* Bootstrap initialization. Registers our image notifier with dyld.
* Called by libSystem BEFORE library initialization time
**********************************************************************/
void _objc_init(void)
{
    ...
    // 省略其他内容，来看我们需要的一个方法，该方法调用了 dyld 库中的方法来注册回调
    _dyld_objc_notify_register(&map_images, load_images, unmap_image);
    ...
}
```

dyld 库中的实现

``` C++
// dyld/dyld_priv.h
//
// Note: only for use by objc runtime
// Register handlers to be called when objc images are mapped, unmapped, and initialized.
// Dyld will call back the "mapped" function with an array of images that contain an objc-image-info section.
// Those images that are dylibs will have the ref-counts automatically bumped, so objc will no longer need to
// call dlopen() on them to keep them from being unloaded.  During the call to _dyld_objc_notify_register(),
// dyld will call the "mapped" function with already loaded objc images.  During any later dlopen() call,
// dyld will also call the "mapped" function.  Dyld will call the "init" function when dyld would be called
// initializers in that image.  This is when objc calls any +load methods in that image.
//
void _dyld_objc_notify_register(_dyld_objc_notify_mapped    mapped,
                                _dyld_objc_notify_init      init,
                                _dyld_objc_notify_unmapped  unmapped);

// dyld/APIs.cpp
void _dyld_objc_notify_register(_dyld_objc_notify_mapped    mapped,
                                _dyld_objc_notify_init      init,
                                _dyld_objc_notify_unmapped  unmapped)
{
    log_apis("_dyld_objc_notify_register(%p, %p, %p)\n", mapped, init, unmapped);

    gAllImages.setObjCNotifiers(mapped, init, unmapped);
}
```

During the call to _dyld_objc_notify_register(), dyld will call the "mapped" function with already loaded objc images.  During any later dlopen() call, dyld will also call the "mapped" function.  Dyld will call the "init" function when dyld would be called initializers in that image.  This is when objc calls any +load methods in that image.

大概意思就是当调用 _dyld_objc_notify_register() 方法时，会调用 `mapped` 方法，并将已经加载的 objc 镜像传入，然后之后再次调用 dlopen 方法时 dyld 会再次调用 mapped 方法并将新加载的镜像传入

我们看一下  `gAllImages.setObjCNotifiers` 的实现

```C++
void AllImages::setObjCNotifiers(_dyld_objc_notify_mapped map, _dyld_objc_notify_init init, _dyld_objc_notify_unmapped unmap)
{
    // 先将三个回调赋值给 AllImages 的成员，供后续调用
    _objcNotifyMapped   = map;
    _objcNotifyInit     = init;
    _objcNotifyUnmapped = unmap;

    ...
    // 省略调中间部分，我们只看 map 调用的部分
    // callback about already loaded images
    uint32_t maxCount = count();
    STACK_ALLOC_ARRAY(const mach_header*, mhs,   maxCount);
    STACK_ALLOC_ARRAY(const char*,        paths, maxCount);
    // don't need _mutex here because this is called when process is still single threaded
    // 遍历已经加载的镜像，并查看是否有 objc 镜像，如果有，就添加到数组中
    for (const LoadedImage& li : _loadedImages) {
        if ( li.image()->hasObjC() ) {
            paths.push_back(imagePath(li.image()));
            mhs.push_back(li.loadedAddress());
        }
    }
    // 如果有加载好的 objc 镜像，那么就调用 map
    if ( !mhs.empty() ) {
        (*map)((uint32_t)mhs.count(), &paths[0], &mhs[0]);
        if ( log_notifications("dyld: objc-mapped-notifier called with %ld images:\n", mhs.count()) ) {
            for (uintptr_t i=0; i < mhs.count(); ++i) {
                log_notifications("dyld:  objc-mapped: %p %s\n",  mhs[i], paths[i]);
            }
        }
    }
}
```

然后再看下 dlopen()

```C++
const MachOLoaded* AllImages::dlopen(Diagnostics& diag, const char* path, bool rtldNoLoad, bool rtldLocal,
                                     bool rtldNoDelete, bool rtldNow, bool fromOFI, const void* callerAddress,
                                     bool canUsePrebuiltSharedCacheClosure)
{
    
    ...
    // 前边代码忽略，我们直接看最后返回了 loadImage
    return loadImage(diag, path, topImageNum, newClosure, rtldLocal, rtldNoDelete, rtldNow, fromOFI, callerAddress);
}

// dlopen method
__attribute__((noinline))
const MachOLoaded* AllImages::loadImage(Diagnostics& diag, const char* path,
                                        closure::ImageNum topImageNum, const closure::DlopenClosure* newClosure,
                                        bool rtldLocal, bool rtldNoDelete, bool rtldNow, bool fromOFI,
                                        const void* callerAddress) {
    ...

    // tell gAllImages about new images
    addImages(newImages);

    // Run notifiers before applyInterposingToDyldCache() as then we have an
    // accurate image list before any calls to findImage().
    // TODO: Can we move this even earlier, eg, after map images but before fixups?
    runImageNotifiers(newImages);

    // if closure adds images that override dyld cache, patch cache
    if ( newClosure != nullptr )
        applyInterposingToDyldCache(newClosure, mach_task_self());
    
    // 该方法会调用 镜像加载的回调，我们继续看
    runImageCallbacks(newImages);

    // run initializers
    runInitialzersBottomUp(topImage);

    return topLoadAddress;
}

void AllImages::runImageCallbacks(const Array<LoadedImage>& newImages)
{
    // 去掉无用的代码，我们看到这里的实现同 setObjCNotifiers 中最后对 map 调用的过程基本相同
    // call objc about images that use objc
    if ( _objcNotifyMapped != nullptr ) {
        const char*         pathsBuffer[count];
        const mach_header*  mhBuffer[count];
        uint32_t            imagesWithObjC = 0;
        for (const LoadedImage& li : newImages) {
            const closure::Image* image = li.image();
            if ( image->hasObjC() ) {
                pathsBuffer[imagesWithObjC] = imagePath(image);
                mhBuffer[imagesWithObjC]    = li.loadedAddress();
               ++imagesWithObjC;
            }
        }
        if ( imagesWithObjC != 0 ) {
            dyld3::ScopedTimer timer(DBG_DYLD_TIMING_OBJC_MAP, 0, 0, 0);
            (*_objcNotifyMapped)(imagesWithObjC, pathsBuffer, mhBuffer);
            if ( log_notifications("dyld: objc-mapped-notifier called with %d images:\n", imagesWithObjC) ) {
                for (uint32_t i=0; i < imagesWithObjC; ++i) {
                    log_notifications("dyld:  objc-mapped: %p %s\n",  mhBuffer[i], pathsBuffer[i]);
                }
            }
        }
    }
}

```

好了，看完了 dyld 中的调用过程，我们继续回到 objc 代码中查看 mapImages 的实现

Code in objc

```C++
// objc-runtime-new.mm
void
map_images(unsigned count, const char * const paths[],
           const struct mach_header * const mhdrs[])
{
    mutex_locker_t lock(runtimeLock);
    return map_images_nolock(count, paths, mhdrs);
}

// objc-os.mm
void 
map_images_nolock(unsigned mhCount, const char * const mhPaths[],
                  const struct mach_header * const mhdrs[])
{
    static bool firstTime = YES;
    header_info *hList[mhCount];
    uint32_t hCount;
    size_t selrefCount = 0;

    // 略过前面的代码，我们直接看 这里调用了 _read_images
    if (hCount > 0) {
        _read_images(hList, hCount, totalClasses, unoptimizedTotalClasses);
    }

    firstTime = NO;
    
    // Call image load funcs after everything is set up.
    for (auto func : loadImageFuncs) {
        for (uint32_t i = 0; i < mhCount; i++) {
            func(mhdrs[i]);
        }
    }
}

// objc-runtime-new.mm
// 通过方法中剩下的注释我么可以看到 _read_images 中所作的事情，我们只保留 Discover categories 这部分代码，然后继续往下看
void _read_images(header_info **hList, uint32_t hCount, int totalClasses, int unoptimizedTotalClasses)
{
    header_info *hi;
    uint32_t hIndex;
    size_t count;
    size_t i;
    Class *resolvedFutureClasses = nil;
    size_t resolvedFutureClassCount = 0;
    static bool doneOnce;
    bool launchTime = NO;
    TimeLogger ts(PrintImageTimes);

    runtimeLock.assertLocked();

#define EACH_HEADER \
    hIndex = 0;         \
    hIndex < hCount && (hi = hList[hIndex]); \
    hIndex++

    if (!doneOnce) {
        doneOnce = YES;
        launchTime = YES;

        ts.log("IMAGE TIMES: first time tasks");
    }

    // Fix up @selector references

    ts.log("IMAGE TIMES: fix up selector references");

    // Discover classes. Fix up unresolved future classes. Mark bundle classes.
    ts.log("IMAGE TIMES: discover classes");

    // Fix up remapped classes
    // Class list and nonlazy class list remain unremapped.
    // Class refs and super refs are remapped for message dispatching.
    
    ts.log("IMAGE TIMES: remap classes");

#if SUPPORT_FIXUP
    // Fix up old objc_msgSend_fixup call sites
    ts.log("IMAGE TIMES: fix up objc_msgSend_fixup");
#endif


    // Discover protocols. Fix up protocol refs.
    ts.log("IMAGE TIMES: discover protocols");

    // Fix up @protocol references
    // Preoptimized images may have the right 
    // answer already but we don't know for sure.
    ts.log("IMAGE TIMES: fix up @protocol references");

    // Discover categories. Only do this after the initial category
    // attachment has been done. For categories present at startup,
    // discovery is deferred until the first load_images call after
    // the call to _dyld_objc_notify_register completes. rdar://problem/53119145
    if (didInitialAttachCategories) {
        for (EACH_HEADER) {
            load_categories_nolock(hi);
        }
    }
    ts.log("IMAGE TIMES: discover categories");

    // Category discovery MUST BE Late to avoid potential races
    // when other threads call the new category code before
    // this thread finishes its fixups.

    // +load handled by prepare_load_methods()

    // Realize non-lazy classes (for +load methods and static instances)
    
    ts.log("IMAGE TIMES: realize non-lazy classes");

    // Realize newly-resolved future classes, in case CF manipulates them
    
    ts.log("IMAGE TIMES: realize future classes");


    // Print preoptimization statistics
#undef EACH_HEADER
}

// objc-runtime-new.mm
static void load_categories_nolock(header_info *hi) {
    bool hasClassProperties = hi->info()->hasCategoryClassProperties();

    size_t count;
    // 定义方法，接收 Category 列表，在 load_categories_nolock 最后调用了该方法并传入 header_info 中包含的 Category
    auto processCatlist = [&](category_t * const *catlist) {
        for (unsigned i = 0; i < count; i++) {
            category_t *cat = catlist[i];
            Class cls = remapClass(cat->cls);
            locstamped_category_t lc{cat, hi};

            if (!cls) {
                // Category's target class is missing (probably weak-linked).
                // Ignore the category.
                if (PrintConnecting) {
                    _objc_inform("CLASS: IGNORING category \?\?\?(%s) %p with "
                                 "missing weak-linked target class",
                                 cat->name, cat);
                }
                continue;
            }

            // Process this category.
            if (cls->isStubClass()) {
                // Stub classes are never realized. Stub classes
                // don't know their metaclass until they're
                // initialized, so we have to add categories with
                // class methods or properties to the stub itself.
                // methodizeClass() will find them and add them to
                // the metaclass as appropriate.
                if (cat->instanceMethods ||
                    cat->protocols ||
                    cat->instanceProperties ||
                    cat->classMethods ||
                    cat->protocols ||
                    (hasClassProperties && cat->_classProperties))
                {
                    objc::unattachedCategories.addForClass(lc, cls);
                }
            } else {
                // First, register the category with its target class.
                // Then, rebuild the class's method lists (etc) if
                // the class is realized.
                // 现将 Category 注册到其目标类中，当类对象初始化后，将类方法列表重建

                // 如果是类对象
                if (cat->instanceMethods ||  cat->protocols
                    ||  cat->instanceProperties)
                {
                    if (cls->isRealized()) {
                        // 我们继续往下看 attachCategories 该方法的实现
                        attachCategories(cls, &lc, 1, ATTACH_EXISTING);
                    } else {
                        objc::unattachedCategories.addForClass(lc, cls);
                    }
                }

                // 如果为元类对象
                if (cat->classMethods  ||  cat->protocols
                    ||  (hasClassProperties && cat->_classProperties))
                {
                    if (cls->ISA()->isRealized()) {
                        attachCategories(cls->ISA(), &lc, 1, ATTACH_EXISTING | ATTACH_METACLASS);
                    } else {
                        objc::unattachedCategories.addForClass(lc, cls->ISA());
                    }
                }
            }
        }
    };

    processCatlist(hi->catlist(&count));
    processCatlist(hi->catlist2(&count));
}

// Attach method lists and properties and protocols from categories to a class.
// Assumes the categories in cats are all loaded and sorted by load order, 
// oldest categories first.
static void
attachCategories(Class cls, const locstamped_category_t *cats_list, uint32_t cats_count,
                 int flags)
{
    /*
     * Only a few classes have more than 64 categories during launch.
     * This uses a little stack, and avoids malloc.
     *
     * Categories must be added in the proper order, which is back
     * to front. To do that with the chunking, we iterate cats_list
     * from front to back, build up the local buffers backwards,
     * and call attachLists on the chunks. attachLists prepends the
     * lists, so the final result is in the expected order.
     */
    constexpr uint32_t ATTACH_BUFSIZ = 64;
    method_list_t   *mlists[ATTACH_BUFSIZ];
    property_list_t *proplists[ATTACH_BUFSIZ];
    protocol_list_t *protolists[ATTACH_BUFSIZ];

    uint32_t mcount = 0;
    uint32_t propcount = 0;
    uint32_t protocount = 0;
    bool fromBundle = NO;
    
    // 先检查是否为元类
    bool isMeta = (flags & ATTACH_METACLASS);
    // 如果没有 class_rw_ext_t 实例则初始化 class_rw_ext_t，用到才会初始化，来优化内存占用
    auto rwe = cls->data()->extAllocIfNeeded();

    // 遍历分类
    for (uint32_t i = 0; i < cats_count; i++) {
        auto& entry = cats_list[i];
        // 获取当前分类的方法列表
        method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
        // 如果不为空，那么就将分类方法列表添加到 class_rw_ext_t 的方法列表中
        if (mlist) {
            // 只有当 mlists 放满之后，才会向 class_rw_ext_t 方法列表中追加
            if (mcount == ATTACH_BUFSIZ) {
                prepareMethodLists(cls, mlists, mcount, NO, fromBundle, __func__);
                // 向 class_rw_ext_t 方法列表中添加分类中的方法列表
                rwe->methods.attachLists(mlists, mcount);
                mcount = 0;
            }
            // 如果未满，那么就先将方法列表存到 mlist 中，到最后再判断 mcount 是否为0，如果不为0，则把最后的 mlists 添加到 class_rw_ext_t 方法列表中
            // 可以看到添加的顺序为从后向前添加，那么最先编译的分类会放到数组最后，编译过程中越靠后的分类优先级越高
            mlists[ATTACH_BUFSIZ - ++mcount] = mlist;
            fromBundle |= entry.hi->isBundle();
        }

        //  对于分类中的属性和协议，同方法列表处理方式基本相同，
        //最后也会用 class_rw_ext_t 对应的成员变量(properties, protocols) 调用 attachLists
        // 将分类中的属性和协议添加到类中

        // 获取当前分类的属性列表
        property_list_t *proplist =
            entry.cat->propertiesForMeta(isMeta, entry.hi);
        if (proplist) {
            if (propcount == ATTACH_BUFSIZ) {
                rwe->properties.attachLists(proplists, propcount);
                propcount = 0;
            }
            proplists[ATTACH_BUFSIZ - ++propcount] = proplist;
        }

        // 获取当前分类的协议列表
        protocol_list_t *protolist = entry.cat->protocolsForMeta(isMeta);
        if (protolist) {
            if (protocount == ATTACH_BUFSIZ) {
                rwe->protocols.attachLists(protolists, protocount);
                protocount = 0;
            }
            protolists[ATTACH_BUFSIZ - ++protocount] = protolist;
        }
    }

    if (mcount > 0) {
        prepareMethodLists(cls, mlists + ATTACH_BUFSIZ - mcount, mcount,
                           NO, fromBundle, __func__);
        rwe->methods.attachLists(mlists + ATTACH_BUFSIZ - mcount, mcount);
        if (flags & ATTACH_EXISTING) {
            flushCaches(cls, __func__, [](Class c){
                // constant caches have been dealt with in prepareMethodLists
                // if the class still is constant here, it's fine to keep
                return !c->cache.isConstantOptimizedCache();
            });
        }
    }

    rwe->properties.attachLists(proplists + ATTACH_BUFSIZ - propcount, propcount);

    rwe->protocols.attachLists(protolists + ATTACH_BUFSIZ - protocount, protocount);
}

void attachLists(List* const * addedLists, uint32_t addedCount) {
        if (addedCount == 0) return;

        if (hasArray()) {
            // many lists -> many lists
            uint32_t oldCount = array()->count;
            uint32_t newCount = oldCount + addedCount;
            // 创建新的列表，大小为当前类中列表大小 + 分类中的列表大小
            array_t *newArray = (array_t *)malloc(array_t::byteSize(newCount));
            newArray->count = newCount;
            array()->count = newCount;
            // 将类中原有的列表放到新列表后面
            for (int i = oldCount - 1; i >= 0; i--)
                newArray->lists[i + addedCount] = array()->lists[i];
            // 在新列表最前面添加分类中的列表
            for (unsigned i = 0; i < addedCount; i++)
                newArray->lists[i] = addedLists[i];
            // 释放原来列表
            free(array());
            // 将新列表赋给类对象
            setArray(newArray);
            validate();
        }
        else if (!list  &&  addedCount == 1) {
            // 0 lists -> 1 list
            list = addedLists[0];
            validate();
        } 
        else {
            // 1 list -> many lists
            Ptr<List> oldList = list;
            uint32_t oldCount = oldList ? 1 : 0;
            uint32_t newCount = oldCount + addedCount;
            setArray((array_t *)malloc(array_t::byteSize(newCount)));
            array()->count = newCount;
            if (oldList) array()->lists[addedCount] = oldList;
            for (unsigned i = 0; i < addedCount; i++)
                array()->lists[i] = addedLists[i];
            validate();
        }
    }

```

至此，分类加载完毕，方法，属性，协议已经全部添加到类对象中。
从 `attachLists` 方法中我们可以看到，分类方法会添加到类方法列表最前面，所以，当分类中定义了与类中相同的方法时，会优先调用分类中的方法


类扩展在编译的时候就已经合并到类中了
```Objective-C
@interface Person()
@property(nonatimic, assign) height;
@end
```

### 类和分类中的 load 方法

```C++
_dyld_objc_notify_register(&map_images, load_images, unmap_image);

```

我们继续来看 `_dyld_objc_notify_register` 传入的 `load_images`，
`load_images` 最后调用了 `call_load_methods`

```C++
// objc-runtime-new.mm
void
load_images(const char *path __unused, const struct mach_header *mh)
{
    if (!didInitialAttachCategories && didCallDyldNotifyRegister) {
        didInitialAttachCategories = true;
        loadAllCategories();
    }

    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
    call_load_methods();
} 

// objc-loadmethod.mm
void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;

    loadMethodLock.assertLocked();

    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
        // 先调用所有 class 的 load 方法
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
        // 然后调用 Category 的 load 方法
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}

static void call_class_loads(void)
{
    int i;
    
    // Detach current loadable list.
    struct loadable_class *classes = loadable_classes;
    int used = loadable_classes_used;
    loadable_classes = nil;
    loadable_classes_allocated = 0;
    loadable_classes_used = 0;
    
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        // 直接拿到类对象，然后直接获取到类对象中方法列表的地址进行调用，这样做可以保证直接调用到类对象中的 +(void)load 方法
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 

        if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        (*load_method)(cls, @selector(load));
    }
    
    // Destroy the detached list.
    if (classes) free(classes);
}

static bool call_category_loads(void)
{
    int i, shift;
    bool new_categories_added = NO;
    
    // Detach current loadable list.
    struct loadable_category *cats = loadable_categories;
    int used = loadable_categories_used;
    int allocated = loadable_categories_allocated;
    loadable_categories = nil;
    loadable_categories_allocated = 0;
    loadable_categories_used = 0;

    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        // 直接拿到分类对象，然后直接获取到分类对象中方法列表的地址进行调用，这样做可以保证直接调用到分类对象中的 +(void)load 方法
        Category cat = cats[i].cat;
        load_method_t load_method = (load_method_t)cats[i].method;
        Class cls;
        if (!cat) continue;

        cls = _category_getClass(cat);
        if (cls  &&  cls->isLoadable()) {
            if (PrintLoading) {
                _objc_inform("LOAD: +[%s(%s) load]\n", 
                             cls->nameForLogging(), 
                             _category_getName(cat));
            }
            (*load_method)(cls, @selector(load));
            cats[i].cat = nil;
        }
    }
    ...

    return new_categories_added;
}
```

通过上面代码我们可以看到，runtime 通过 load_images -> call_load_methods 来调用 `load` 方法
其调用顺序为，通过指针先调用所有类的 load 方法，然后再调用所有分类的 load 方法，类和分类的load 方法调用顺序为编译顺序
因为在加载完之后分类方法已经都合并到类中，包括 load 方法，所以在调用的时候需要直接拿到 类或分类对象本身，然后直接拿到方法列表指针，然后再进行调用，这样能保证我们看到的调用顺序


+load 方法会在 runtime 加载类、分类是调用
每个类、分类的 +load，在程序运行过程中只调用一次

- 调用顺序
- - 先调用类的 +load （按照编译先后顺序调用，先编译先调用，调用子类的 load 之前会先调用父类的 load）
- - 在调用分类的 load（同样按照编译先后顺序调用）

为保证父类的 load 优先调用，通过 prepare_load_methods->schedule_class_load 将编译后的类进行重排，来保证父类在最前
```C++
void prepare_load_methods(const headerType *mhdr)
{
    size_t count, i;

    runtimeLock.assertLocked();

    classref_t const *classlist = 
        _getObjc2NonlazyClassList(mhdr, &count);
    for (i = 0; i < count; i++) {
        schedule_class_load(remapClass(classlist[i]));
    }

    category_t * const *categorylist = _getObjc2NonlazyCategoryList(mhdr, &count);
    for (i = 0; i < count; i++) {
        category_t *cat = categorylist[i];
        Class cls = remapClass(cat->cls);
        if (!cls) continue;  // category for ignored weak-linked class
        if (cls->isSwiftStable()) {
            _objc_fatal("Swift class extensions and categories on Swift "
                        "classes are not allowed to have +load methods");
        }
        realizeClassWithoutSwift(cls, nil);
        ASSERT(cls->ISA()->isRealized());
        add_category_to_loadable_list(cat);
    }
}
static void schedule_class_load(Class cls)
{
    if (!cls) return;
    ASSERT(cls->isRealized());  // _read_images should realize

    if (cls->data()->flags & RW_LOADED) return;

    // Ensure superclass-first ordering
    schedule_class_load(cls->getSuperclass());

    add_class_to_loadable_list(cls);
    cls->setInfo(RW_LOADED); 
}
```

### 类和分类中的 +initialize 方法

`+initialize` 方法是在类第一次接受消息的时候调用的
每个类只调用一次，`initialize` 是通过消息转发（objc_msgSend）调用的，so 同一个类只会调用一次，并且类中的 `initialize` 会被分类中的 `initialize` 覆盖掉

调用顺序
先调用父类的 +initialize 方法，然后再调用自己的 +initialize 方法

Source Code
```C++
Method class_getClassMethod(Class cls, SEL sel)
{
    if (!cls  ||  !sel) return nil;

    return class_getInstanceMethod(cls->getMeta(), sel);
}

Method class_getInstanceMethod(Class cls, SEL sel)
{
    if (!cls  ||  !sel) return nil;

    // This deliberately avoids +initialize because it historically did so.

    // This implementation is a bit weird because it's the only place that 
    // wants a Method instead of an IMP.

#warning fixme build and search caches
        
    // Search method lists, try method resolver, etc.
    lookUpImpOrForward(nil, sel, cls, LOOKUP_RESOLVER);

#warning fixme build and search caches

    return _class_getMethod(cls, sel);
}

IMP lookUpImpOrForward(id inst, SEL sel, Class cls, int behavior)
{
    const IMP forward_imp = (IMP)_objc_msgForward_impcache;
    IMP imp = nil;
    Class curClass;

    ...
    // 这里调用了 realizeAndInitializeIfNeeded_locked， 我们继续往下看
    cls = realizeAndInitializeIfNeeded_locked(inst, cls, behavior & LOOKUP_INITIALIZE);
    // runtimeLock may have been dropped but is now locked again
    runtimeLock.assertLocked();
    curClass = cls;
    ...
    runtimeLock.unlock();
    if (slowpath((behavior & LOOKUP_NIL) && imp == forward_imp)) {
        return nil;
    }
    return imp;
}

static Class
realizeAndInitializeIfNeeded_locked(id inst, Class cls, bool initialize)
{
    if (slowpath(initialize && !cls->isInitialized())) {
        // 找一下 initializeAndLeaveLocked 的实现
        cls = initializeAndLeaveLocked(cls, inst, runtimeLock);
        // runtimeLock may have been dropped but is now locked again

        // If sel == initialize, class_initialize will send +initialize and
        // then the messenger will send +initialize again after this
        // procedure finishes. Of course, if this is not being called
        // from the messenger then it won't happen. 2778172
    }
    return cls;
}

static Class initializeAndLeaveLocked(Class cls, id obj, mutex_t& lock)
{
    return initializeAndMaybeRelock(cls, obj, lock, true);
}

/***********************************************************************
* class_initialize.  Send the '+initialize' message on demand to any
* uninitialized class. Force initialization of superclasses first.
* inst is an instance of cls, or nil. Non-nil is better for performance.
* Returns the class pointer. If the class was unrealized then 
* it may be reallocated.
* Locking: 
*   runtimeLock must be held by the caller
*   This function may drop the lock.
*   On exit the lock is re-acquired or dropped as requested by leaveLocked.
**********************************************************************/
static Class initializeAndMaybeRelock(Class cls, id inst,
                                      mutex_t& lock, bool leaveLocked)
{
    ...
    initializeNonMetaClass(nonmeta);
    ...
}

void initializeNonMetaClass(Class cls)
{
    ASSERT(!cls->isMetaClass());

    Class supercls;
    bool reallyInitialize = NO;

    // Make sure super is done initializing BEFORE beginning to initialize cls.
    // See note about deadlock above.
    supercls = cls->getSuperclass();
    ...
    // 如果有父类，并且父类没有调用 Initialize，那么先去通过递归调用父类的 Initialize
    if (supercls  &&  !supercls->isInitialized()) {
        initializeNonMetaClass(supercls);
    }
    ...
    // 最后调用自己的 initialize 方法
            callInitialize(cls);
    ...

}

void callInitialize(Class cls)
{
    ((void(*)(Class, SEL))objc_msgSend)(cls, @selector(initialize));
    asm("");
}
```


- `+initialize` 和 `+load` 最大的区别是，+initialize 是通过 objc_msgSend 进行调用的，所以会有以下特点
- - 如果子类没有实现 `+initialize`，会调用父类的 `+initialize`，（所以父类的 +initialize 可能会被调用多次，但是父类自己只调用一次）
- - 如果分类实现了 `+initialize`，就会覆盖类本身的 `+initialize` 调用
- `+initialize` 方法是在类第一次接受消息的时候调用的
- `+load` 是在类和分类加载的时候调用的
- 先调用父类的 `+initialize` 方法，然后再调用自己的 `+initialize` 方法