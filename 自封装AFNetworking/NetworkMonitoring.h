//
//  NetworkMonitoring.h
//  DemoThree
//
//  Created by 刘恒 on 15/9/10.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetworkChangeBlock)(AFNetworkReachabilityStatus);
@interface NetworkMonitoring : NSObject<UIAlertViewDelegate>

/**
 AFNetworkReachabilityStatusUnknown          = -1,  // 未知
 AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
 AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G、4G
 AFNetworkReachabilityStatusReachableViaWiFi = 2,   // WiFi
 */

@property (nonatomic, assign)AFNetworkReachabilityStatus network;

/**
 *  网络变化时回调方法
 */
@property (nonatomic, copy)NetworkChangeBlock networkChangeBlock;

/**
 *  获取网路状态（默认开启）
 *
 *  @return 网络当前状态
 */
+ (AFNetworkReachabilityStatus)sharedNetworkMonitoring;

/**
 *  关闭监听
 */
+ (void)stopNetworkMonitoring;
@end
