//
//  ViewController.m
//  MagicalRecord
//
//  Created by 颜风 on 15/12/9.
//  Copyright © 2015年 iOS122. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"详见源文件ViewcControll.m" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    /* 实体对象的创建保存与更新 */
    // 获取上下文环境
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    
    // 在当前上下文环境中创建一个新的 Person 对象.
    Person *person  = [Person MR_createEntityInContext:defaultContext];
    person.firstname = @"firstname";
    person.lastname  = @"lastname";
    person.age       = @100;
    
    // 保存修改到当前上下文中.
    [defaultContext MR_saveToPersistentStoreAndWait];
    
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        Person *localPerson = [person MR_inContext:localContext];
        localPerson.firstname = @"Yan";
        localPerson.lastname = @"Feng";
    }  completion:^(BOOL success, NSError *error) {
        
        NSArray * persons = [Person MR_findAllSortedBy:@"lastname:YES"
                                                                     ascending:NO];
        
        [persons enumerateObjectsUsingBlock:^(Person * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"firstname: %@, lastname: %@\n", obj.firstname, obj.lastname);
        }];
        
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
