//
//  DispatchQueueAdaption.h
//  KKWords
//
//  Created by Kanzaki Mirai on 1/9/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DispatchQueueAdaption : NSObject

typedef void (^ DispatchCodeBlock)();
+ (void)dispatch_async_global_queue:(DispatchCodeBlock)block;

@end
