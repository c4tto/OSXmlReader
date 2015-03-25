//
//  NSObject+OSXmlKeyClassDeterminer.m
//  OSXmlReader
//
//  Created by Ondrej Stocek on 25.03.15.
//
//

#import <objc/runtime.h>

#import "NSObject+OSXmlKeyClassDeterminer.h"

@implementation NSObject (OSXmlKeyClassDeterminer)

+ (Class)classOfKey:(NSString *)key
{
    objc_property_t property = class_getProperty(self, [key UTF8String]);
    if (property) {
        const char *type = property_getAttributes(property);
        NSString *typeString = [NSString stringWithUTF8String:type];
        NSArray *attributes = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = attributes[0];
        
        if ([typeAttribute hasPrefix:@"T@"] && typeAttribute.length > 4) {
            NSString *typeName = [typeAttribute substringWithRange:NSMakeRange(3, typeAttribute.length - 4)]; // turns e.g. @"NSDate" into NSDate
            return NSClassFromString(typeName);
        } else {
            return [NSNumber class]; // all static builtin types can be stored in NSNumber
        }
    }
    return nil;
}

+ (Class)classOfKeyPath:(NSString *)keyPath
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    Class class = self;
    for (NSString *key in keys) {
        class = [class classOfKey:key];
        if (!class) {
            break;
        }
    }
    return class;
}


@end
