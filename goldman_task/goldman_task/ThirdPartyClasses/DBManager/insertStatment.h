//
//  insertStatment.h
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface insertStatment : NSObject {
    
@protected
    NSString *_table;
    NSMutableDictionary *_column;
    
}

/*!
 @method				into:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-10-30
 */
- (void) into: (NSString *)table;
/*!
 @method				column:value:
 @discussion			This method will add a column/value pair to the SQL statement.
 @param column			The column where the value will be inserted.
 @param value			The value to be inserted.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column value: (id)value;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;


@end
