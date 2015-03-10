@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (instancetype)defaultCenter;
+ (instancetype)notificationCenterForType:(id)arg1;

- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4 suspensionBehavior:(unsigned int)arg5;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (id)addObserverForName:(id)arg1 object:(id)arg2 queue:(id)arg3 usingBlock:(id)arg4;
- (id)addObserverForName:(id)arg1 object:(id)arg2 suspensionBehavior:(unsigned int)arg3 queue:(id)arg4 usingBlock:(id)arg5;
- (id)init;
- (void)postNotification:(id)arg1;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 options:(unsigned int)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
- (void)postNotificationName:(id)arg1 object:(id)arg2;
- (void)removeObserver:(id)arg1 name:(id)arg2 object:(id)arg3;
- (void)setSuspended:(BOOL)arg1;
- (BOOL)suspended;

@end
