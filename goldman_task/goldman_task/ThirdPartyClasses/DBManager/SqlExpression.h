/*
 * Copyright 2011-2015 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import <Foundation/Foundation.h>

// Block Statement Tokens
#define ZIMSqlEnclosureOpeningBrace				@"("
#define ZIMSqlEnclosureClosingBrace				@")"

// Connectors
#define ZIMSqlConnectorAnd						@"AND"
#define ZIMSqlConnectorOr						@"OR"

// Join Types -- http://sqlite.org/syntaxdiagrams.html#join-op
#define ZIMSqlJoinTypeCross						@"CROSS"
#define ZIMSqlJoinTypeInner						@"INNER"
#define ZIMSqlJoinTypeLeft						@"LEFT"
#define ZIMSqlJoinTypeLeftOuter					@"LEFT OUTER"
#define ZIMSqlJoinTypeNatural					@"NATURAL"
#define ZIMSqlJoinTypeNaturalCross				@"NATURAL CROSS"
#define ZIMSqlJoinTypeNaturalInner				@"NATURAL INNER"
#define ZIMSqlJoinTypeNaturalLeft				@"NATURAL LEFT"
#define ZIMSqlJoinTypeNaturalLeftOuter			@"NATURAL LEFT OUTER"
#define ZIMSqlJoinTypeNone						@""

// Expressions -- http://zetcode.com/databases/sqlitetutorial/expressions/
// Arithmetic Operators
#define ZIMSqlOperatorAdd						@"+"
#define ZIMSqlOperatorSubtract					@"-"
#define ZIMSqlOperatorMultiply					@"*"
#define ZIMSqlOperatorDivide					@"/"
#define ZIMSqlOperatorMod						@"%"

// Boolean Operators
#define ZIMSqlOperatorAnd						@"AND"
#define ZIMSqlOperatorOr						@"OR"
#define ZIMSqlOperatorNot						@"NOT"

// Relational Operators
#define ZIMSqlOperatorLessThan					@"<"
#define ZIMSqlOperatorLessThanOrEqualTo			@"<="
#define ZIMSqlOperatorGreaterThan				@">"
#define ZIMSqlOperatorGreaterThanOrEqualTo		@">="
#define ZIMSqlOperatorEqualTo					@"="
#define ZIMSqlOperatorNotEqualTo				@"<>"

// Bitwise Operators
#define ZIMSqlOperatorBitwiseAnd				@"&"
#define ZIMSqlOperatorBitwiseOr					@"|"
#define ZIMSqlOperatorBitwiseShiftLeft			@"<<"
#define ZIMSqlOperatorBitwiseShiftRight			@">>"
#define ZIMSqlOperatorBitwiseNegation			@"~"

// Additional Operators
#define ZIMSqlOperatorConcatenate				@"||"
#define ZIMSqlOperatorIn						@"IN"
#define ZIMSqlOperatorNotIn						@"NOT IN"
#define ZIMSqlOperatorIs						@"IS"
#define ZIMSqlOperatorIsNot						@"IS NOT"
#define ZIMSqlOperatorLike						@"LIKE"
#define ZIMSqlOperatorNotLike					@"NOT LIKE"
#define ZIMSqlOperatorGlob						@"GLOB"
#define ZIMSqlOperatorNotGlob					@"NOT GLOB"
#define ZIMSqlOperatorBetween					@"BETWEEN"
#define ZIMSqlOperatorNotBetween				@"NOT BETWEEN"

// Set Operators
#define ZIMSqlOperatorExcept					@"EXCEPT"
#define ZIMSqlOperatorIntersect					@"INTERSECT"
#define ZIMSqlOperatorUnion						@"UNION"
#define ZIMSqlOperatorUnionAll					@"UNION ALL"

// Show Types
#define ZIMSqlShowTypeAll						@"ALL"
#define ZIMSqlShowTypePermanent					@"PERMANENT"
#define ZIMSqlShowTypeTemporary					@"TEMPORARY"

// Order Operators (for Nulls)
#define ZIMSqlNullsFirst						@"FIRST"
#define ZIMSqlNullsLast							@"LAST"

// Default Values -- http://forums.realsoftware.com/viewtopic.php?f=3&t=35179
#define ZIMSqlDefaultValueIsAutoIncremented		@"PRIMARY KEY AUTOINCREMENT NOT NULL"
#define ZIMSqlDefaultValueIsNull				@"DEFAULT NULL"
#define ZIMSqlDefaultValueIsNotNull				@"NOT NULL"
#define ZIMSqlDefaultValueIsCurrentDate			@"DEFAULT CURRENT_DATE"
#define ZIMSqlDefaultValueIsCurrentDateTime		@"DEFAULT (datetime('now','localtime'))"
#define ZIMSqlDefaultValueIsCurrentTime			@"DEFAULT CURRENT_TIME"
#define ZIMSqlDefaultValueIsCurrentTimestamp	@"DEFAULT CURRENT_TIMESTAMP"
NSString *ZIMSqlDefaultValue(id value);

// Declared Datetype -- http://www.sqlite.org/datatype3.html
#define ZIMSqlDataTypeBigInt					@"BIGINT"
#define ZIMSqlDataTypeBlob						@"BLOB"
#define ZIMSqlDataTypeBoolean					@"BOOLEAN"
#define ZIMSqlDataTypeClob						@"CLOB"
#define ZIMSqlDataTypeDate						@"DATE"
#define ZIMSqlDataTypeDateTime					@"DATETIME"
#define ZIMSqlDataTypeDouble					@"DOUBLE"
#define ZIMSqlDataTypeDoublePrecision			@"DOUBLE PRECISION"
#define ZIMSqlDataTypeFloat						@"FLOAT"
#define ZIMSqlDataTypeInt						@"INT"
#define ZIMSqlDataTypeInt2						@"INT2"
#define ZIMSqlDataTypeInt8						@"INT8"
#define ZIMSqlDataTypeInteger					@"INTEGER"
#define ZIMSqlDataTypeMediumInt					@"MEDIUMINT"
#define ZIMSqlDataTypeNumeric					@"NUMERIC"
#define ZIMSqlDataTypeReal						@"REAL"
#define ZIMSqlDataTypeSmallInt					@"SMALLINT"
#define ZIMSqlDataTypeText						@"TEXT"
#define ZIMSqlDataTypeTimestamp					@"TIMESTAMP"
#define ZIMSqlDataTypeTinyInt					@"TINYINT"
#define ZIMSqlDataTypeUnsignedBigInt			@"UNSIGNED BIG INT"
#define ZIMSqlDataTypeVariant					@"VARIANT"


/*!
 @class					ZIMSqlExpression
 @discussion			This class handles the formatting of an SQL expression.
 @updated				2012-04-04
 */
@interface SqlExpression : NSObject {

	@protected
		NSString *_expression;

}
+ (NSString *) prepareValue: (id)value ;
+ (NSString *) prepareSortOrder: (BOOL)descending;
+ (NSString *) prepareSortWeight: (NSString *)weight;
+ (NSString *) prepareConnector: (NSString *)token;
+ (NSString *) prepareJoinType: (NSString *)token;
+ (NSString *) prepareAlias: (NSString *)token;
+ (NSString *) prepareEnclosure: (NSString *)token;
+ (NSString *) prepareOperator: (NSString *)operator ofType: (NSString *)type;
+ (BOOL) matchesRegex: (NSString *)pattern options: (NSRegularExpressionOptions)options :(NSString *)token;
@end
