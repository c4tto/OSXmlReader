//
//  OSXmlReader.m
//  OSXmlReader
//
//  Created by Ondrej Stocek on 12.1.11.
//
//

#import <objc/runtime.h>

#import "OSXmlReader.h"
#import "NSObject+OSXmlKeyClassDeterminer.h"

@interface OSXmlReaderField : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *xpathMapping;
@property (copy, nonatomic) OSXmlConvertBlock convertBlock;
@property (strong, nonatomic) OSXmlReader *reader;
@end

@implementation OSXmlReaderField
@end

@interface OSXmlReader ()
@property (strong, nonatomic, readonly) NSMutableDictionary *fields;
@end

@implementation OSXmlReader

@synthesize fields = _fields;

- (instancetype)initWithRecordType:(Class)recordType
{
    self = [self init];
    if (self) {
        _recordType = recordType;
    }
    return self;
}

- (NSMutableDictionary *)fields
{
    if (!_fields) {
        _fields = [NSMutableDictionary dictionary];
    }
    return _fields;
}

- (NSString *)recordXPath
{
    if (!_recordXPath) {
        _recordXPath = @"/*";
    }
    return _recordXPath;
}

- (OSXmlReaderField *)fieldForName:(NSString *)name
{
    OSXmlReaderField *field = self.fields[name];
    if (!field) {
        field = [[OSXmlReaderField alloc] init];
        field.name = name;
        self.fields[name] = field;
    }
    return field;
}

- (id)convertStringValue:(NSString *)value toType:(Class)type
{
    if ([type isSubclassOfClass:[NSString class]]) {
        return value;
    } else if ([type isSubclassOfClass:[NSNumber class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = [formatter numberFromString:value];
        if (!number) { // BOOL fallback
            NSArray *yesValues = @[@"yes", @"true", @"y", @"on"];
            BOOL boolValue = NO;
            for (NSString *yes in yesValues) {
                if ([value caseInsensitiveCompare:yes] == NSOrderedSame) {
                    boolValue = YES;
                }
            }
            number = [NSNumber numberWithBool:boolValue];
        }
        return number;
    }
    return value;
}

- (void)createPathInRecord:(id)record forKeyPath:(NSString *)keyPath
{
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"."];
    NSArray *keys = [keyPath componentsSeparatedByCharactersInSet:delimiters];
    
    for (NSUInteger i = 0; i < keys.count - 1; ++i) {
        NSString *key = keys[i];
        if (![record valueForKey:key]) {
            Class class = [[record class] classOfKey:key];
            if (class) {
                id value = [[class alloc] init];
                [record setValue:value forKey:key];
                record = value;
            } else {
                break;
            }
        }
    }
}

- (id)readRecordXmlNode:(GDataXMLNode *)recordNode
{
    id record = self.recordType ? [[self.recordType alloc] init] : [NSMutableDictionary dictionaryWithCapacity:self.fields.count];
    
    for (NSString *name in self.fields) {
        OSXmlReaderField *field = self.fields[name];
        NSError *error;
        
        if (field.reader) {
            [field.reader readXmlNode:recordNode];
            [record setValue:field.reader.records forKey:name];
        } else if (field.xpathMapping) {
            NSArray *valueNodes = [recordNode nodesForXPath:field.xpathMapping error:&error];
            if (error) {
                _error = error;
                return nil;
            }
            if (valueNodes.count > 0) {
                GDataXMLNode *valueNode = valueNodes[0];
                
                id value = field.convertBlock ? field.convertBlock(valueNodes, recordNode, self.rootNode) : valueNode.stringValue;
                Class class = [[record class] classOfKeyPath:name];
                if (class && [value isKindOfClass:[NSString class]]) {
                    value = [self convertStringValue:value toType:class];
                }
                
                [self createPathInRecord:record forKeyPath:name];
                [record setValue:value forKeyPath:name];
            }
        }
    }
    return [self convertRecord:record fromRecordNode:recordNode rootNode:self.rootNode];
}

- (BOOL)readXmlData:(NSData *)xmlData
{
    NSError *error;
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData error:&error];
    if (!error) {
        return [self readXmlDocument:document];
    } else {
        _error = error;
        return NO;
    }
}

- (BOOL)readXmlString:(NSString *)xmlString
{
    NSError *error;
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xmlString error:&error];
    if (!error) {
        return [self readXmlDocument:document];
    } else {
        _error = error;
        return NO;
    }
}

- (BOOL)readXmlDocument:(GDataXMLDocument *)document
{
    return [self readXmlNode:document.rootElement];
}

- (BOOL)readXmlNode:(GDataXMLNode *)rootNode
{
    _rootNode = rootNode;
    
    NSError *error;
    NSArray *recordNodes = [rootNode nodesForXPath:self.recordXPath error:&error];
    if (error) {
        _error = error;
        return NO;
    }
    
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:recordNodes.count];
    for (GDataXMLNode *recordNode in recordNodes) {
        id record = [self readRecordXmlNode:recordNode];
        if (record) {
            [records addObject:record];
        } else {
            return NO;
        }
    }
    
    _records = records;
    return YES;
}

- (void)setXPathMapping:(NSString *)xpathMapping forProperty:(NSString *)propertyName
{
    OSXmlReaderField *field = [self fieldForName:propertyName];
    field.xpathMapping = xpathMapping;
}

- (void)setXPathMapping:(NSString *)xpathMapping forProperty:(NSString *)propertyName convertBlock:(OSXmlConvertBlock)convertBlock
{
    OSXmlReaderField *field = [self fieldForName:propertyName];
    field.xpathMapping = xpathMapping;
    field.convertBlock = convertBlock;
}

- (void)setXmlReader:(OSXmlReader *)reader forProperty:(NSString *)propertyName
{
    OSXmlReaderField *field = [self fieldForName:propertyName];
    field.reader = reader;
}

- (id)convertRecord:(id)record fromRecordNode:(GDataXMLNode *)recordNode rootNode:(GDataXMLNode *)rootNode
{
    return record;
}

@end
