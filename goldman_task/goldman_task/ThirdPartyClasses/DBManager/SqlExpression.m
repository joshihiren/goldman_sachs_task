//
//  sqlExpression.m
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import "SqlExpression.h"
#import <sqlite3.h> // Requires libsqlite3.dylib

@implementation SqlExpression

+ (NSString *) prepareValue: (id)value
{
    if ((value == nil) || [value isKindOfClass: [NSNull class]])
    {
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

+ (NSString *) prepareConnector: (NSString *)token
{
    if (![self matchesRegex:@"^(and|or)$" options:NSRegularExpressionCaseInsensitive :token])
    {
        @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid connector token provided." userInfo: nil];
    }
    return [token uppercaseString];
}

+ (BOOL) matchesRegex: (NSString *)pattern options: (NSRegularExpressionOptions)options :(NSString *)token{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern options: options error: &error];
    if (regex == nil) {
        return NO;
    }
    NSUInteger n = [regex numberOfMatchesInString: token options: 0 range: NSMakeRange(0, [token length])];
    return (n == 1);
}

+ (NSString *) prepareSortOrder: (BOOL)descending {
    return (descending) ? @"DESC" : @"ASC";
}

+ (NSString *) prepareSortWeight: (NSString *)weight {
    if (weight != nil)
    {
        if (![self matchesRegex:@"^(first|last)$" options:NSRegularExpressionCaseInsensitive :weight])
        {
            @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid weight token provided." userInfo: nil];
        }
        return [weight uppercaseString];
    }
    return @"DEFAULT";
}

+ (NSString *) prepareJoinType: (NSString *)token {
    if ((token == nil) || [token isEqualToString: ZIMSqlJoinTypeNone]) {
        token = ZIMSqlJoinTypeInner;
    }
    else if ([token isEqualToString: @","]) {
        token = ZIMSqlJoinTypeCross;
    }
    if (![self matchesRegex: @"^((natural )?(cross|inner|(left( outer)?)))|(natural)$" options:NSRegularExpressionCaseInsensitive :token])
    {
        @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid join type token provided." userInfo: nil];
    }
    return [token uppercaseString];
}

+ (NSString *) prepareAlias: (NSString *)token {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"[^a-z0-9_ ]" options: NSRegularExpressionCaseInsensitive error: &error];
    token = [regex stringByReplacingMatchesInString: token options: 0 range: NSMakeRange(0, [token length]) withTemplate: @""];
    token = [token stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    token = [NSString stringWithFormat: @"[%@]", token];
    return token;
}

+ (NSString *) prepareEnclosure: (NSString *)token {
    if (!([token isEqualToString: ZIMSqlEnclosureOpeningBrace] || [token isEqualToString: ZIMSqlEnclosureClosingBrace])) {
        @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid enclosure token provided." userInfo: nil];
    }
    return token;
}

+ (NSString *) prepareOperator: (NSString *)operator ofType: (NSString *)type
{
   
    if ([[type uppercaseString] isEqualToString: @"SET"] && ![self matchesRegex: @"^(except|intersect|(union( all)?))$" options: NSRegularExpressionCaseInsensitive:operator]) {
        @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid set operator token provided." userInfo: nil];
    }
    return [operator uppercaseString];
}


@end
