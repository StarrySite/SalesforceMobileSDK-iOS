//
//  NSData+SFAdditions.h
//  SalesforceCommonUtils
//
//
//  Copyright (c) 2008-2012 salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**Extension to NSData class to provide common functions
 
 Added functionalities include 
 base64 encode of a NSData
 MD5 of a NSData
 Gzip deflat of a gzip compressed NSData
 Hex version of a NSData
 */
@interface NSData (SFBase64)

/**
 @return The specified number of random bytes or `nil` if an error occurs.
 */
- (NSData *)randomDataOfLength:(size_t)length;

/**Create a new base64 encoding of this NSData
 */
-(NSString *)newBase64Encoding;

/**Return base64 encoded string for the currrent NSData
 */
-(NSString *)base64Encode;

/**Create a new base64 encoding of this NSData. 
 
 Similar to `newBase64Encoding`
 */
-(id)initWithBase64String:(NSString *)base64;

+(NSData *)dataFromBase64String:(NSString *)encoding;

@end


@interface NSData (SFMD5)

/**Return md5 version of this NSData*/
- (NSString *)md5;
@end

@interface NSData (SFzlib)

/**Return gzip uncompressed version of the this NSData*/
-(NSData *)gzipInflate;
/**Return gzip compressed version of the this NSData*/
-(NSData *)gzipDeflate;
@end


@interface NSData (SFHexSupport)

/** Return a hex string representation of the data contained in receiver
 */
- (NSString*)newHexStringFromBytes;

@end
