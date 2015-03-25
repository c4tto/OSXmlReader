//
//  NSObject+OSXmlKeyDeterminer.h
//  OSXmlReader
//
//  Created by Ondřej Štoček on 25.03.15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (OSXmlKeyDeterminer)

+ (Class)classOfKey:(NSString *)key;
+ (Class)classOfKeyPath:(NSString *)keyPath;

@end
