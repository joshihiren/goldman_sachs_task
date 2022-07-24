//
//  DBManager.h
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject
////{
////    sqlite3 *db;
////    NSString *documentsPath;
////    
////}
//@property (nonatomic, readwrite) sqlite3 *db;
//@property(nonatomic, strong) NSString *documentsPath;
//+(instancetype)sharedManager;
//-(BOOL)executeQuery:(NSString *)sql;
//-(NSArray *)loadDataFromDB:(NSString *)query;
////-(void)initDatabase;
-(BOOL)createTable:(NSString*)tableName createTableQuery:(NSString*)createTableQuery;
@property(nonatomic, strong) NSString *documentsPath;
+(instancetype) sharedManager;
@property (nonatomic, strong) NSMutableArray *arrColumnNames;
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

-(NSArray *)loadDataFromDB:(NSString *)query;

-(BOOL)executeQuery:(NSString *)query;

@end
