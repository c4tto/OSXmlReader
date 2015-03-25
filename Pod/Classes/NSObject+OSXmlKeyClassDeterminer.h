//
//  NSObject+OSXmlKeyClassDeterminer.h
//  OSXmlReader
//
//  Created by Ondrej Stocek on 25.03.15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (OSXmlKeyClassDeterminer)

+ (Class)classOfKey:(NSString *)key;
+ (Class)classOfKeyPath:(NSString *)keyPath;

@end
