//
//  DBManager.m
//
//  Created by Hiren Joshi on 19/11/16.
//  Copyright © 2016 Hiren. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

dispatch_queue_t  databaseQueue;
@interface DBManager()
@property (nonatomic, strong) NSMutableArray *arrResults;
-(void)copyDatabaseIntoDocumentsDirectory;
-(BOOL)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
@end

@implementation DBManager

static dispatch_once_t pred;
static id shared = nil;
+(instancetype)sharedManager {
    dispatch_once(&pred, ^
                  {
                      databaseQueue = dispatch_queue_create("hiren.database", DISPATCH_QUEUE_SERIAL);
                      shared = [[super alloc] initWithDatabaseFilename:@"Taskdatabase.db"];
                  });
    return shared;
}
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename
{
    self = [super init];
    if (self)
    {
         [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}
-(NSArray *)loadDataFromDB:(NSString *)query
{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}
-(BOOL)executeQuery:(NSString *)query
{
    return [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

-(BOOL)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable
{
//    RCLog(@"runQuery=>query %s",query);
    size_t length= strlen(query);
    __block BOOL isSuceed = false;
    if(length>0)
    {
        
        dispatch_sync(databaseQueue, ^{
            // your database activity
            
            
            // Create a sqlite object.
            sqlite3 *sqlite3Database;
            
            
            // Initialize the results array.
            //        if (self.arrResults != nil) {
            //            [self.arrResults removeAllObjects];
            //            self.arrResults = nil;
            //        }
            self.arrResults = [[NSMutableArray alloc] init];
            
            // Initialize the column names array.
            if (self.arrColumnNames != nil) {
                [self.arrColumnNames removeAllObjects];
                self.arrColumnNames = nil;
            }
            self.arrColumnNames = [[NSMutableArray alloc] init];
            
            
            // Open the database.
            BOOL openDatabaseResult = sqlite3_open([self.documentsPath UTF8String], &sqlite3Database);
            if(openDatabaseResult == SQLITE_OK) {
                // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
                sqlite3_stmt *compiledStatement;
                
                // Load all data from database to memory.
                BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
                if(prepareStatementResult == SQLITE_OK)
                {
                    // Check if the query is non-executable.
                    if (!queryExecutable){
                        
                        // In this case data must be loaded from the database.
                        
                        // Declare an array to keep the data for each fetched row.
                        NSMutableArray *arrDataRow;
                        
                        // Loop through the results and add them to the results array row by row.
                        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                            // Initialize the mutable array that will contain the data of a fetched row.
                            arrDataRow = [[NSMutableArray alloc] init];
                            
                            // Get the total number of columns.
                            int totalColumns = sqlite3_column_count(compiledStatement);
                            
                            // Go through all columns and fetch each column data.
                            for (int i=0; i<totalColumns; i++){
                                // Convert the column data to text (characters).
                                char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                                
                                // If there are contents in the currenct column (field) then add them to the current row array.
                                if (dbDataAsChars != NULL) {
                                    // Convert the characters to string.
                                    [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                                }
                                else
                                {
                                    [arrDataRow addObject:[NSString  stringWithFormat:@""]];
                                }
                                
                                // Keep the current column name.
                                if (self.arrColumnNames.count != totalColumns) {
                                    dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                                    [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                                }
                            }
                            
                            // Store each fetched data row in the results array, but first check if there is actually data.
                            if (arrDataRow.count > 0)
                            {
                                
                                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                                for (int i=0;i<arrDataRow.count;i++)
                                {
                                    [dictionary setValue:[arrDataRow objectAtIndex:i] forKey:[self.arrColumnNames objectAtIndex:i]];
                                    
                                }
                                [self.arrResults addObject:dictionary];
                            }
                        }
                        //                    RCLog(@"Get Data Done");
                        isSuceed = true;
                    }
                    else
                    {
                        uint8_t executeQueryResults = sqlite3_step(compiledStatement);
                        
                        if (executeQueryResults == SQLITE_DONE)
                        {
                            //                        RCLog(@"Done");
                            isSuceed = true;
                        }
                        else {
                            // If could not execute the query show the error message on the debugger.
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //FIXME: Remove Toast
                                [self runQuery:query isQueryExecutable:queryExecutable];
                            });
                            
                            isSuceed = false;
                            
                            //FIXME: Check this ---
                            NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                            NSLog(@"on Query: %s", query);
                        }
                        
                    }
                }
                else
                {
                    // In the database cannot be opened then show the error message on the debugger.
                    NSLog(@"prepareStatementResult error => %s  and query is %s", sqlite3_errmsg(sqlite3Database),query);
                    isSuceed = false;
                }
                
                // Release the compiled statement from memory.
                sqlite3_finalize(compiledStatement);
                
            }
            // Close the database.
            sqlite3_close(sqlite3Database);
        });
    }
    else
    {
        NSLog(@"runQuery length error");
        isSuceed = false;
    }
    
    return isSuceed;
}
-(void)copyDatabaseIntoDocumentsDirectory
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Taskdatabase" ofType:@"sqlite"];
    
    NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"Taskdatabase"] stringByAppendingPathExtension:@"sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"copyItemAtPath: %@", self.documentsPath );
    if (![fileManager fileExistsAtPath:self.documentsPath])
    {
        NSError *error = nil;
        BOOL success = [fileManager copyItemAtPath:bundlePath toPath:self.documentsPath error:&error];
        NSAssert(success, @"%s: copyItemAtPath: %@", __FUNCTION__, error);
    }
    else
    {
        NSLog(@"%s: copyItemAtPath", __FUNCTION__);
    }
}
-(BOOL)createTable:(NSString*)tableName createTableQuery:(NSString*)createTableQuery
{
    sqlite3 *db;
    const char *dbpath = [self.documentsPath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errMsg;
        
        NSString *strCheckTable = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';",tableName];
        sqlite3_stmt *statementChk;
        sqlite3_prepare_v2(db,[strCheckTable UTF8String], -1, &statementChk, nil);
        
        if (sqlite3_step(statementChk) == SQLITE_ROW) {
            sqlite3_finalize(statementChk);
            sqlite3_close(db);
            return true;
        }
        else
        {
            if (sqlite3_exec(db, [createTableQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create %@ errMsg   %s" ,tableName,errMsg);
                sqlite3_finalize(statementChk);
                sqlite3_close(db);
                return false;
            }
            else
            {
                sqlite3_finalize(statementChk);
                sqlite3_close(db);
                return true;
            }
        }
    }
    else
    {
        NSLog(@"Failed to open/create database");
        sqlite3_close(db);
        return false;
    }
}

/*

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable
{
    self.arrResults = [[NSMutableArray alloc] init];
    const char *dbpath = [self.documentsPath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        // Initialize the results array.
        if (self.arrResults != nil) {
            [self.arrResults removeAllObjects];
            self.arrResults = nil;
        }
        self.arrResults = [[NSMutableArray alloc] init];
        
        // Initialize the column names array.
        if (self.arrColumnNames != nil) {
            [self.arrColumnNames removeAllObjects];
            self.arrColumnNames = nil;
        }
        self.arrColumnNames = [[NSMutableArray alloc] init];
        
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(db, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK)
        {
            // Check if the query is non-executable.
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        else
                        {
                            [arrDataRow addObject:[NSString  stringWithFormat:@""]];
                        }
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0)
                    {
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                        for (int i=0;i<arrDataRow.count;i++)
                        {
                            [dictionary setValue:[arrDataRow objectAtIndex:i] forKey:[self.arrColumnNames objectAtIndex:i]];
                        }
                        [self.arrResults addObject:dictionary];
                    }
                }
            }
        }
        else
        {
            // In the database cannot be opened then show the error message on the debugger.
            RCLog(@"%s", sqlite3_errmsg(db));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        // Close the database.
        sqlite3_close(db);
    }
    else
    {
        RCLog(@"Failed to open DB")
        ;
        sqlite3_close(db);
    }
}

+(instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initDatabase];
    });
    return sharedMyManager;
}

-(instancetype)initDatabase
{
    self = [super init];
    if (self)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"RCDB" ofType:@"sqlite"];
        NSString *documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        self.documentsPath   = [[documentsFolder stringByAppendingPathComponent:@"RCDB"] stringByAppendingPathExtension:@"sqlite"]; 
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:self.documentsPath])
        {
            NSError *error = nil;
            BOOL success = [fileManager copyItemAtPath:bundlePath toPath:self.documentsPath error:&error];
            NSAssert(success, @"%s: copyItemAtPath: %@", __FUNCTION__, error);
        }
        else
        {
            RCLog(@"%s: copyItemAtPath", __FUNCTION__);
        }
    }
    return self;
}
-(BOOL)createTable:(NSString*)tableName createTableQuery:(NSString*)createTableQuery
{
        const char *dbpath = [self.documentsPath UTF8String];
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
            char *errMsg;

            NSString *strCheckTable = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';",tableName];
            sqlite3_stmt *statementChk;
            sqlite3_prepare_v2(db,[strCheckTable UTF8String], -1, &statementChk, nil);
            
            if (sqlite3_step(statementChk) == SQLITE_ROW) {
                sqlite3_finalize(statementChk);
                sqlite3_close(db);
                return true;
            }
            else
            {
                if (sqlite3_exec(db, [createTableQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
                    RCLog(@"Failed to create %@ errMsg   %s" ,tableName,errMsg);
                    sqlite3_finalize(statementChk);
                    sqlite3_close(db);
                    return false;
                }
                else
                {
                    sqlite3_finalize(statementChk);
                    sqlite3_close(db);
                    return true;
                }
            }
        }
        else
        {
            RCLog(@"Failed to open/create database")
            ;
            sqlite3_close(db);
            return false;
        }
}
*/

@end

