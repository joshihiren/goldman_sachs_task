//
//  updateStatment.m
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import "updateStatment.h"
#import "SqlExpression.h"

@implementation updateStatment
- (instancetype) init {
    if ((self = [super init])) {
        _table = nil;
        _column = [[NSMutableArray alloc] init];
        _where = [[NSMutableArray alloc] init];
        _orderBy = [[NSMutableArray alloc] init];
        _limit = 0;
        _offset = 0;
    }
    return self;
}

- (void) table: (NSString *)table {
    _table = table;
}

- (void) column: (NSString *)column value: (id)value
{
    if ((value == nil) || [value isKindOfClass: [NSNull class]])
    {
        value = @"";
    }
    [_column addObject: [NSString stringWithFormat: @"%@ = %@", column, [SqlExpression prepareValue: value]]];
}

- (void) whereBlock: (NSString *)brace {
    [self whereBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) whereBlock: (NSString *)brace connector: (NSString *)connector {
    [_where addObject: @[[SqlExpression prepareConnector: connector], [SqlExpression prepareEnclosure: brace]]];
}

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 {
    [self where: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
    [_where addObject: @[[SqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", column1, [operator uppercaseString], column2]]];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value {
    [self where: column operator: operator value: value connector: ZIMSqlConnectorAnd];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
    operator = [operator uppercaseString];
    if ([operator isEqualToString: ZIMSqlOperatorBetween] || [operator isEqualToString: ZIMSqlOperatorNotBetween]) {
        if (![value isKindOfClass: [NSArray class]]) {
            @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
        }
        [_where addObject: @[[SqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@ AND %@", column, operator, [SqlExpression prepareValue: [(NSArray *)value objectAtIndex: 0]], [SqlExpression prepareValue: [(NSArray *)value objectAtIndex: 1]]]]];
    }
    else {
        if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
            @throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
        }
        else if ([value isKindOfClass: [NSNull class]]) {
            if ([operator isEqualToString: ZIMSqlOperatorEqualTo]) {
                operator = ZIMSqlOperatorIs;
            }
            else if ([operator isEqualToString: ZIMSqlOperatorNotEqualTo] || [operator isEqualToString: @"!="]) {
                operator = ZIMSqlOperatorIsNot;
            }
        }
        [_where addObject: @[[SqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", column, operator, [SqlExpression prepareValue: value]]]];
    }
}

- (void) orderBy: (NSString *)column {
    [self orderBy: column descending: NO nulls: nil];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending {
    [self orderBy: column descending: descending nulls: nil];
}

- (void) orderBy: (NSString *)column nulls: (NSString *)weight {
    [self orderBy: column descending: NO nulls: weight];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending nulls: (NSString *)weight {
    NSString *field = column;
    NSString *order = [SqlExpression prepareSortOrder: descending];
    weight = [SqlExpression prepareSortWeight: weight];
    if ([weight isEqualToString: @"FIRST"]) {
        [_orderBy addObject: [NSString stringWithFormat: @"CASE WHEN %@ IS NULL THEN 0 ELSE 1 END, %@ %@", field, field, order]];
    }
    else if ([weight isEqualToString: @"LAST"]) {
        [_orderBy addObject: [NSString stringWithFormat: @"CASE WHEN %@ IS NULL THEN 1 ELSE 0 END, %@ %@", field, field, order]];
    }
    else {
        [_orderBy addObject: [NSString stringWithFormat: @"%@ %@", field, order]];
    }
}

- (void) limit: (NSUInteger)limit {
    _limit = limit;
}

- (void) limit: (NSUInteger)limit offset: (NSUInteger)offset {
    _limit = limit;
    _offset = offset;
}

- (void) offset: (NSUInteger)offset {
    _offset = offset;
}

- (NSString *) statement {
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendFormat: @"UPDATE %@ SET ", _table];
    
    if ([_column count] > 0) {
        [sql appendString: [_column componentsJoinedByString: @", "]];
    }
    
    if ([_where count] > 0) {
        BOOL doAppendConnector = NO;
        [sql appendString: @" WHERE "];
        for (NSArray *where in _where) {
            NSString *whereClause = [where objectAtIndex: 1];
            if (doAppendConnector && ![whereClause isEqualToString: ZIMSqlEnclosureClosingBrace]) {
                [sql appendFormat: @" %@ ", [where objectAtIndex: 0]];
            }
            [sql appendString: whereClause];
            doAppendConnector = (![whereClause isEqualToString: ZIMSqlEnclosureOpeningBrace]);
        }
    }
    
    if ([_orderBy count] > 0) {
        [sql appendFormat: @" ORDER BY %@", [_orderBy componentsJoinedByString: @", "]];
    }
    
    if (_limit > 0) {
        [sql appendFormat: @" LIMIT %lu", (unsigned long)_limit];
    }
    
    if (_offset > 0) {
        [sql appendFormat: @" OFFSET %lu", (unsigned long)_offset];
    }
    
    [sql appendString: @";"];
    
    return sql;
}

@end
