//
//  ViewController.m
//  SQLite Using C Library 1
//
//  Created by danny on 2014/2/6.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self testDatabase];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testDatabase
{
    //
	char		*sqlStatement;
	sqlite3		*pDb;
	char		*errorMsg;
	int			returnCode;

    NSString *sqlitepath = [[NSBundle mainBundle] pathForResource:@"sqlitedata" ofType:@"db"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:sqlitepath]){
        NSLog(@"檔案存在！");
        //這裡放置如果檔案存在時的程式
    }else{
        NSLog(@"檔案不存在！");
    }

    NSLog(@"%@",sqlitepath);
    
    const char *databaseFileName =[sqlitepath UTF8String];
    
    returnCode= sqlite3_open(databaseFileName, &pDb);
	if(returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in opening the database. Error: %s", sqlite3_errmsg(pDb));
		sqlite3_close(pDb);
		return;
	}

    NSString *n1=[NSString stringWithUTF8String:databaseFileName];
    NSString *n2=[NSString stringWithCString:databaseFileName encoding:NSUTF8StringEncoding];
    NSLog(@"\n=====\n%@  %@",n1,n2);
	sqlStatement =  "DROP TABLE IF EXISTS  stocks";
	returnCode = sqlite3_exec(pDb, sqlStatement, NULL, NULL, &errorMsg);
	if(returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in droping table stocks. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}
    
	
	sqlStatement =  "CREATE TABLE stocks (symbol VARCHAR(5), "
    "purchasePrice FLOAT(10,4), unitsPurchased INTEGER, purchase_date VARCHAR(10))";
	returnCode = sqlite3_exec(pDb, sqlStatement, NULL, NULL, &errorMsg);
	if(returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in creating the stocks table. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}
    //
	insertData(pDb, "ALU",  14.23, 100, "03-17-2012");
	insertData(pDb, "GOOG",  600.77, 20, "01-09-2012");
	insertData(pDb, "NT",  20.23, 140, "02-05-2012");
	insertData(pDb, "MSFT",  30.23, 5, "01-03-2012");
	insertData(pDb, "中文測試！",  30.23, 5, "01-03-2012");
    //

	sqlStatement =  "SELECT * from stocks";
	returnCode = sqlite3_exec(pDb, sqlStatement, processRow, NULL, &errorMsg);
	if(returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in selecting from stocks table. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}

	sqlite3_close(pDb);

}

void insertData(sqlite3 *pDb, const char*symbol, float price, int units, const char* date){
	char		*errorMsg;
	int			returnCode;
	char		*st;
	st	= sqlite3_mprintf("INSERT INTO stocks VALUES ('%q', %f, %d, '%q')",
                          symbol, price, units, date);
	returnCode = sqlite3_exec(pDb, st, NULL, NULL, &errorMsg);
	if(returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in inserting into the stocks table. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}
	sqlite3_free(st);
}
//
static int processRow(void *argument, int argc, char **argv, char **colName){
	printf("Record Data:\n");
	for(int i=0; i<argc; i++){
		printf("The value for Column Name %s is equal to %s\n", colName[i], argv[i] ? argv[i] : "NULL");
	}
	printf("\n");
	return 0;
}
//


@end
