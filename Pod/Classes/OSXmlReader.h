//
//  OSXmlReader.h
//  OSXmlReader
//
//  Created by Ondrej Stocek on 25.3.2015.
//
//

// libxml includes require that the target Header Search Paths contain
//
//   /usr/include/libxml2
//
// and Other Linker Flags contain
//
//   -lxml2

#import <GDataXML-HTML/GDataXMLNode.h>

/** Block using for converting output values
 * @param valueNodes - array of GDataXmlNode value nodes searched by XPath
 * @param recordNode - record node search by record XPath @see recordXPath
 * @param rootNode - root node of read XML
 */
typedef id (^OSXmlConvertBlock)(NSArray *valueNodes, GDataXMLNode *recordNode, GDataXMLNode *rootNode);

/** XML Reader
 */
@interface OSXmlReader : NSObject

/** basic xpath where record parts of xml can be found, default is "/ *"
 */
@property (strong, nonatomic) NSString *recordXPath;

/** recordType class of output records, default is NSDictionary
 */
@property (assign, nonatomic) Class recordType;

/** An array of output records
 */
@property (strong, nonatomic, readonly) NSArray *records;

/** error
 */
@property (strong, nonatomic, readonly) NSError *error;

/** root node of read XML
 */
@property (strong, nonatomic, readonly) GDataXMLNode *rootNode;

/** Init method
 * @param recordType - class of output records, nil means NSDictionary
 */
- (instancetype)initWithRecordType:(Class)recordType;

/** Sets xpath mapping from XML to property of output record class
 * @see setXpathMapping:forProperty:convertBlock definition
 */
- (void)setXPathMapping:(NSString *)xpathMapping forProperty:(NSString *)propertyName;

/** Sets xpath mapping from XML to property of output record class with optional convert block
 * @param xpathMapping - mapping string from XML
 * @param propertyName - name of property in output record class
 * @param convertBlock - block where can be adjusted value from reader
 * @see OSXmlConvertBlock definition
 */
- (void)setXPathMapping:(NSString *)xpathMapping forProperty:(NSString *)propertyName convertBlock:(OSXmlConvertBlock)convertBlock;

/** Sets XML reader for nested record collection
 * @param xmlReader - nested reader
 * @param property Name - name of property in output record class. Must be subclass of NSArray in this case
 */
- (void)setXmlReader:(OSXmlReader *)xmlReader forProperty:(NSString *)propertyName;

/** Performs XML reading of XML document
 * @param document
 * @return success (records or error are stored in property)
 * @see records, error
 */
- (BOOL)readXmlDocument:(GDataXMLDocument *)document;

/** Performs XML reading of XML node
 * @param rootNode
 * @return success (records or error are stored in property)
 * @see records, error
 */
- (BOOL)readXmlNode:(GDataXMLNode *)rootNode;

/** Performs XML reading of data containing XML
 * @param data
 * @return success (records or error are stored in property)
 * @see records, error
 */
- (BOOL)readXmlData:(NSData *)data;

/** Perform XML reading of XML string
 * @param xmlString
 * @return success
 * @see records, error
 */
- (BOOL)readXmlString:(NSString *)xmlString;

/** Post procession of records. This method is launched for every output record.
 * Method is used for overriding, this implementation does nothing.
 * @param record - output record from this reader
 * @param recordNode - xml record node for additional usage
 * @param rootNode - xml root node for additional usage
 */
- (id)convertRecord:(id)record fromRecordNode:(GDataXMLNode *)recordNode rootNode:(GDataXMLNode *)rootNode;

@end
