//
//  XCZQuote.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-5.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@interface XCZQuote ()

@property (strong, nonatomic) NSString *quoteTr;
@property (strong, nonatomic) NSString *authorTr;
@property (strong, nonatomic) NSString *workTr;

@end

@implementation XCZQuote

// 获取一条随机摘录
+ (XCZQuote *)getRandomQuote
{
    XCZQuote * quote = [[XCZQuote alloc] init];
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM quotes ORDER BY RANDOM() LIMIT 1"];
        [s next];
        [quote loadFromResultSet:s];
        [db close];
    }
    
    return quote;
}

+ (XCZQuote *)getRandomQuoteExcept:(NSArray *)quoteIds
{
    XCZQuote * quote = [[XCZQuote alloc] init];
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM quotes WHERE id NOT IN (%@) ORDER BY RANDOM() LIMIT 1", [quoteIds componentsJoinedByString:@", "]];
        FMResultSet *s = [db executeQuery:queryString];
        [s next];
        [quote loadFromResultSet:s];
        [db close];
    }
    
    return quote;
}

// 获取某文学家的一条随机摘录
+ (XCZQuote *)getRandomQuoteByAuthorId:(int)authorId
{
    XCZQuote * quote = nil;
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM quotes WHERE author_id = %d ORDER BY RANDOM() LIMIT 1", authorId];
        FMResultSet *s = [db executeQuery:query];
        
        if ([s next]) {
            quote = [XCZQuote new];
            [quote loadFromResultSet:s];
        }
        
        [db close];
    }
    
    return quote;
}

// 获取所有摘录
+ (NSArray *)getAll
{
    int index = 0;
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        NSString *query = @"SELECT * FROM quotes";
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZQuote *quote = [XCZQuote new];
            [quote loadFromResultSet:s];
            quotes[index] = quote;
            index++;
        }
        
        [db close];
    }
    
    return quotes;
}

// 获取某文学家的所有摘录
+ (NSArray *)getByAuthorId:(int)authorId
{
    int index = 0;
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM quotes WHERE author_id = %d", authorId];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZQuote *quote = [XCZQuote new];
            [quote loadFromResultSet:s];
            quotes[index] = quote;
            index++;
        }
        
        [db close];
    }
    
    return quotes;
}

// 获取某作品的所有摘录
+ (NSArray *)getByWorkId:(int)workId
{
    int index = 0;
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM quotes WHERE work_id = %d", workId];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZQuote *quote = [XCZQuote new];
            [quote loadFromResultSet:s];
            quotes[index] = quote;
            index++;
        }
        
        [db close];
    }
    
    return quotes;
}

// 获取一定数目的摘录
+ (NSMutableArray *)getRandomQuotes:(int)number
{
    int index = 0;
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    
    // 从SQLite中加载数据
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM quotes ORDER BY RANDOM() LIMIT %d", number];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZQuote *quote = [[XCZQuote alloc] init];
            [quote loadFromResultSet:s];
            quotes[index] = quote;
            index++;
        }
        
        [db close];
    }
    
    return quotes;
}

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.authorId = [resultSet intForColumn:@"author_id"];
    self.workId = [resultSet intForColumn:@"work_id"];
    
    self.quote = [resultSet stringForColumn:@"quote"];
    self.author = [resultSet stringForColumn:@"author"];
    self.work = [resultSet stringForColumn:@"work"];

    self.quoteTr = [resultSet stringForColumn:@"quote_tr"];
    self.authorTr = [resultSet stringForColumn:@"author_tr"];
    self.workTr = [resultSet stringForColumn:@"work_tr"];
}

#pragma mark - Getters & Setters

- (NSString *)quote
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _quote;
    } else {
        return _quoteTr;
    }
}

- (NSString *)author
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _author;
    } else {
        return _authorTr;
    }
}

- (NSString *)work
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _work;
    } else {
        return _workTr;
    }
}

- (NSArray *)pieces
{
    if (!_pieces) {
        __block NSInteger prevLocation = 0;
        NSMutableArray *results = [NSMutableArray new];
        NSString *pattern = @"[，。：；？！、]";
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        
        NSRange range = NSMakeRange(0,[self.quote length]);
        [expression enumerateMatchesInString:self.quote options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange range = [result rangeAtIndex:0];
            NSString *quoteText = [self.quote substringWithRange:NSMakeRange(prevLocation, range.location - prevLocation)];
            
            [results addObject:quoteText];
            prevLocation = range.location + 1;
        }];
        
        _pieces = results;
    }
    
    return _pieces;
}

@end
