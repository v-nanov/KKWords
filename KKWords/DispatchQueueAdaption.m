//
//  DispatchQueueAdaption.m
//  KKWords
//
//  Created by Kanzaki Mirai on 1/9/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

#import "DispatchQueueAdaption.h"

// because macOS 10.9 cannot use DispatchQueue.global(), so bridge back to objc

@implementation DispatchQueueAdaption

+ (void)dispatch_async_global_queue:(DispatchCodeBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
