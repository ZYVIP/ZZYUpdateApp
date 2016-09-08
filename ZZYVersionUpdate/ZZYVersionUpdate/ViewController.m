//
//  ViewController.m
//  ZZYVersionUpdate
//
//  Created by admin on 16/9/5.
//  Copyright © 2016年 断剑. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import <SVProgressHUD.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UITableView * table;

@property (nonatomic, weak) NSArray * dataArray;
/**
 *  appStore版本号
 */
@property (nonatomic, copy) NSString * appStoreVersion;
/**
 *  本地版本号
 */
@property (nonatomic, copy) NSString * localVersion;
/**
 *  appStore下载链接
 */
@property (nonatomic, copy) NSString * urlStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
    UITableView * table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    table.showsHorizontalScrollIndicator = NO;
    table.showsVerticalScrollIndicator = NO;
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    table.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:table];
    self.table = table;

    [table mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.topMargin.equalTo(self.view).offset(40);
        make.leftMargin.equalTo(self.view).offset(0);
        make.rightMargin.equalTo(self.view).offset(0);
        make.height.mas_equalTo(self.view.frame.size.height);
    }];
    
    
}


- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        if([self isShowUpdate])
        {
            _dataArray = [NSArray arrayWithObjects:@"版本更新", @"清理缓存",@"关于我们", nil];
        }
        else
        {
            _dataArray = [NSArray arrayWithObjects: @"清理缓存",@"关于我们", nil];

        }
    }
    return _dataArray;
}

- (BOOL)isShowUpdate
{
    //获取Appstore中信息
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSDictionary * dict = app.appDict;
    
    
    NSArray * results = dict[@"results"];
    
    //获取版本号与对应的下载链接
    for (NSDictionary * dict in results) {
        self.appStoreVersion = dict[@"version"];
        
        self.urlStr = dict[@"trackViewUrl"];
        
    }
    
    //获取本地版本号
    self.localVersion = [[NSBundle mainBundle]infoDictionary][@"CFBundleVersion"];
    
    NSLog(@"appVersion %@ localVersion %@ ",self.appStoreVersion ,self.localVersion );
    
    //比较AppStore版本号与本地版本号的大小
//    if([self.appStoreVersion compare:self.localVersion] == NSOrderedAscending)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
    
    return [self checkVersion:self.localVersion isNewThanVersion:self.appStoreVersion];
    
    
}

/**
 *  比较版本号的大小
 *
 *  @param localVersion 当前版本号
 *  @param appSroreVersion appStore版本号
 *
 *  @return appStore版本号是否大于当前版本号
 
 *   当前版本号（用户为用户版本号，审核为Xcode开发版本号）
     appStore版本号是 大于或等于 当前版本号 显示更新
 */
-(BOOL)checkVersion:(NSString *)localVersion isNewThanVersion:(NSString *)appSroreVersion{
    NSArray * locol = [localVersion componentsSeparatedByString:@"."];
    NSArray * appStore = [appSroreVersion componentsSeparatedByString:@"."];
    
    for (NSUInteger i=0; i<locol.count; i++) {
        NSInteger locolV = [[locol objectAtIndex:i] integerValue];
        NSInteger appStoreV = appStore.count > i ? [[appStore objectAtIndex:i] integerValue] : 0;
        if (locolV > appStoreV) {
            return NO;
        }
        else if (locolV == appStoreV || locolV < appStoreV) {
            return YES;
        }
    }
    return NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.section];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isShowUpdate]) {
        switch (indexPath.section) {
            case 0:
            {
                //版本更新
                NSString * message = nil;
                
                if ([self.localVersion compare:self.appStoreVersion] == NSOrderedSame) {
                    //当前是最新版本
                    NSLog(@"当前是最新版本");
                    message = @"当前是最新版本";
                    
                }
                else if ([self.localVersion compare:self.appStoreVersion] == NSOrderedAscending)
                {
                    NSLog(@"更新版本");
                    message = [NSString stringWithFormat:@"请点击更新最新版本:%@",self.appStoreVersion];
                    
                }
                
                
                if (![message isEqualToString:@"当前是最新版本"]) {
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlStr]];
                        
                        
                        
                    }]];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
                else
                {
                    [SVProgressHUD showSuccessWithStatus:message];                }
  
                
            }
                break;
            case 1:
            {
                //清理缓存
            }
                break;
            case 2:
            {
                //关于我们
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.section) {
            
            case 0:
            {
                //清理缓存
            }
                break;
            case 1:
            {
                //关于我们
            }
                break;
                
            default:
                break;
        }

    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
