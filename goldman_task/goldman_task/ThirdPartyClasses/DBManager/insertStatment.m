//
//  insertStatment.m
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import "insertStatment.h"
#import <sqlite3.h> 



@implementation insertStatment

- (instancetype) init {
    if ((self = [super init])) {
        _table = nil;
        _column = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) into: (NSString *)table {
    //_table = [ZIMSqlExpression prepareIdentifier: table];
    _table = table;
}

- (void) column: (NSString *)column value: (id)value
{
    if ((value == nil) || [value isKindOfClass: [NSNull class]])
    {
        value = @"";
    }
//    RCLog(@"[self prepareValue: value] %@",[self prepareValue: value]);
    
    [_column setObject: [self prepareValue: value] forKey: column];
    
    //[_column setObject: value forKey: column];
}

- (NSString *) statement {
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendFormat: @"INSERT INTO %@ ", _table];
    
    if ([_column count] > 0) {
        [sql appendFormat: @"(%@) VALUES (%@)", [[_column allKeys] componentsJoinedByString: @", "], [[_column allValues] componentsJoinedByString: @", "]];
    }
    
    [sql appendString: @";"];
    return sql;
}
- (NSString *) prepareValue: (id)value {
    if ((value == nil) || [value isKindOfClass: [NSNull class]]) {
        return @"NULL";
    }
    else if ([value isKindOfClass: [NSArray class]]) {
        NSMutableString *buffer = [[NSMutableString alloc] init];
        [buffer appendString: @"("];
        for (NSInteger i = 0; i < [value count]; i++) {
            if (i > 0) {
                [buffer appendString: @", "];
            }
            [buffer appendString: [self prepareValue: [value objectAtIndex: i]]];
        }
        [buffer appendString: @")"];
        return buffer;
    }
    else if ([value isKindOfClass: [NSNumber class]]) {
        return [NSString stringWithFormat: @"%@", value];
    }
    else if ([value isKindOfClass: [NSString class]]) {
        char *escapedValue = sqlite3_mprintf("'%q'", [(NSString *)value UTF8String]);
        NSString *string = [NSString stringWithUTF8String: (const char *)escapedValue];
        sqlite3_free(escapedValue);
        return string;
    }
    else if ([value isKindOfClass: [NSData class]]) {
        NSData *data = (NSData *)value;
        NSInteger length = [data length];
        NSMutableString *buffer = [[NSMutableString alloc] init];
        [buffer appendString: @"x'"];
        const unsigned char *dataBuffer = [data bytes];
        for (NSInteger i = 0; i < length; i++) {
            [buffer appendFormat: @"%02lx", (unsigned long)dataBuffer[i]];
        }
        [buffer appendString: @"'"];
        return buffer;
    }
    else if ([value isKindOfClass: [NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSString *date = [NSString stringWithFormat: @"'%@'", [formatter stringFromDate: (NSDate *)value]];
        return date;
    }
    else {
        @throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Unable to prepare value. '%@'", value] userInfo: nil];
    }
}

@end
