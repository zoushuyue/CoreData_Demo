//
//  ViewController.m
//  CoreData_Demo
//
//  Created by mac1 on 16/8/17.
//  Copyright © 2016年 fuxi. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Hero.h"

@interface ViewController () {
    
    NSManagedObjectContext *context;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", NSHomeDirectory());
    
    [self createCoreDataBase];
    
//    [self addObject];
    
   
    
//    [self deleteObjects];
    
    [self updateObjects];
    
     [self queryObjects];
}

//创建数据库
-(void)createCoreDataBase{
    
    //CoreData:
    //根据CoreDataModel文件,在磁盘中创建sqlite文件
    
    
    //1 NSManagedObjectModel
    //xcdatamodeld文件编译打包到bundle中,转变成momd文件
    NSURL *dataUrl = [[NSBundle mainBundle]URLForResource:@"CoreDataModel" withExtension:@"momd"];
    
    NSManagedObjectModel *dataModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:dataUrl];
    
    //2 根据dataModel对象创建协调器
    
    // 1>创建协调器 (建立数据<--->MO对象的联系)
    // 使用这个对象，间接操作数据库文件
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:dataModel];
    
    //2>给协调器对象添加一个持久化的对象
    /*CoreData支持的存储数据的文件类型
     NSSQLiteStoreType:SQLite
     NSXMLStoreType    XML
     NSBinaryStoreType 二进制
     NSInMemoryStoreType 只保存在内存中
     */
    
    //数据库文件在沙盒保存的路径
    NSString *persistentPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/PersistentStore.sqlite"];
    
    NSURL *persistentUrl = [NSURL fileURLWithPath:persistentPath];
    
    NSError *addError = nil;
    [psc addPersistentStoreWithType:NSSQLiteStoreType
                      configuration:nil //配置
                                URL:persistentUrl //数据库文件保存的路径
                            options:nil error:&addError];
    
    
    //3 保存数据模型的上下文
    context = [[NSManagedObjectContext alloc]init];
    //指定contex使用哪个协调器写入数据库
    context.persistentStoreCoordinator = psc;
    
    
    
}

//添加数据
-(void)addObject{
    
    //0 创建model模型
    
    /*
     //添加一条数据 (MO对象)
     Hero *h1 = [[Hero alloc]init];
     
     //将MO对象添加到上下文中
     [context insertObject:h1];
     
     h1.name = @"haha";
     
     [context save:nil];
     */
    
    //创建MO对象,使用实体描述类
    /*
     EntityForName:data model文件中的哪个实体
     Context:要插入的上下文
     */
    Hero *h1 = [NSEntityDescription insertNewObjectForEntityForName:@"Hero"
                                             inManagedObjectContext:context];
    h1.name = @"猪八戒";
    h1.heroId = @101;
    h1.team = @"西天取经队";
    h1.height = @250;
    
    //把上下文的变化保存下来
    NSError *saveError = nil;
    [context save:&saveError];
    
    
}

//查询数据
- (void) queryObjects {
    
    //1 抓取请求
    NSFetchRequest *fetchedRequest = [NSFetchRequest fetchRequestWithEntityName:@"Hero"];
    //1）查询的条件（谓词）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height > %f", 1.0];
    fetchedRequest.predicate = predicate;
    
    //2)排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:YES];//升序
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"heroId" ascending:YES];
    fetchedRequest.sortDescriptors = @[sort1, sort2];
    
    //3）限制查询的条数
//    fetchedRequest.fetchLimit = 20;
    
    //4)从第几天数据开始返回
//    fetchedRequest .fetchOffset = 3;
    
    //2 执行查询请求
    NSArray *result = [context executeFetchRequest:fetchedRequest error:nil];
    
    for (Hero *h in result) {
        
        NSLog(@"heroId = %@, name = %@", h.heroId, h.name);
    }
}

//删除数据
- (void) deleteObjects {
    
    //1 抓取请求
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Hero"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height > %f", 10.0];
    fetchRequest.predicate = predicate;
    
    //2 执行请求
    NSArray *heros = [context executeFetchRequest:fetchRequest error:nil];
    
    for (Hero *h in heros) {
        
        //删除
        [context deleteObject:h];
    }
    
    //3 保存
    [context save:NULL];
}

//修改数据
- (void) updateObjects {
    
    NSFetchRequest *fetchRes = [NSFetchRequest fetchRequestWithEntityName:@"Hero"];
    //1)指定查询的实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hero" inManagedObjectContext:context];
    [fetchRes setEntity:entity];
    
    //2) 查询的条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height > %f", 100];
    [fetchRes setPredicate:predicate];
    
    //3)排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"height" ascending:YES];
    [fetchRes setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    //4)执行
    NSError *error = nil;
    NSArray *fetchObjects = [context executeFetchRequest:fetchRes error:&error];
    
    for (Hero *h in fetchObjects) {
        
        h.name = @"沙僧";
        h.height = @5.0;
//        h.heroId = @103;
        
    }
    
    //5)保存
    [context save:NULL];
}
@end
