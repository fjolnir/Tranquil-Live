//
//  TPluginManager.h
//  Tranquil
//
//  Created by Fjölnir Ásgeirsson on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPluginManager : NSObject
+ (TPluginManager *)sharedManager;

- (void)loadAllPlugins;
- (void)loadPluginInDirectory:(NSString *)aPath;
- (BOOL)loadPluginAtPath:(NSString *)aPath;
@end
