//
//  GiftController.m
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "GiftController.h"
#import "SSWL_ErrorView.h"


@interface GiftController ()

@property (nonatomic, assign) int func;

@property (nonatomic, strong) SSWL_ErrorView *errorView;




//@property (nonatomic, strong) UIImageView *noNetImgView;
//
//@property (nonatomic, strong) UILabel *netTipsLabel;

@end

@implementation GiftController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIApplication *app = [UIApplication sharedApplication];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(applicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:app];
    
    [self loadDataToWebView];
   
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"toGame"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getMsg"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"statistics"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"doShare"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getCopyValue"];

    
//        //首先设置UIInterfaceOrientationUnknown欺骗系统，避免可能出现直接设置无效的情况
//        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
//        
//        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    SYLog(@"页面将要出现");
    
   
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"toGame"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getMsg"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"statistics"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"doShare"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getCopyValue"];

    SYLog(@"页面将要消失");

}
/*
 * 爸爸类没有链接,
 * 自行load
 */
- (void)loadDataToWebView{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];

}

/*
 * 自己看爸爸类
 */
- (void)isLoadData:(BOOL)isLoad{
    SYLog(@"子类实现.....");
    SYLog(@"-----isLoad:%d", isLoad);
}

- (void)isNetWorking:(BOOL)isNetWorking{
    if (!isNetWorking) {
        SYLog(@"没网");
        if (self.webView) {
            self.webView.hidden = YES;
            [self.progressView setHidden:YES];
            [self.view addSubview:self.errorView];
        }
    }
}


- (void)touchTap:(UITapGestureRecognizer *)sender{
    SYLog(@"%s",__FUNCTION__);
    [self loadDataToWebView];
    self.webView.hidden = NO;
    self.progressView.hidden = NO;
    if (self.errorView) {
        self.errorView.hidden = YES;
        self.errorView = nil;
    }
    
}
 

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//    SYLog(@"%@", message.body);
    if ([message.name isEqualToString:@"toGame"]) {
        /**
         *       self.barHidden = YES
         *    爸爸会自动识别,并把状态栏给隐藏 (屌不屌)
         */
        self.barHidden = YES;//在这里设置yes
        [self isBarHidden];
        if (self.WebBlock) {
            self.WebBlock();
            
        }
    }
    /*给前端签名(屌不屌)*/
    if ([message.name isEqualToString:@"getInfo"]) {
        [self sendDataForPrama:message.body messageName:message.name];
    }
    if ([message.name isEqualToString:@"statistics"]){
        [self statisticsAllEventWithMessageName:message.name Param:message.body];
    }
    
    if ([message.name isEqualToString:@"doShare"]){
        [self doShareWithMessageName:message.name param:message.body];
    }
    
    if ([message.name isEqualToString:@"getCopyValue"]) {
        [self getGiftCValueWithMessageName:message.name param:message.body];
    }
    
}

- (void)getGiftCValueWithMessageName:(NSString *)name param:(NSString *)param{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = param;
    if (pasteboard.string.length > 1) {
        [SSWL_PublicTool showAlertToViewController:self alertControllerTitle:@"复制成功" alertControllerMessage:nil alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:^(UIAlertAction * _Nonnull action) {
            
        } reportHandler:nil completion:^{
            
        }];
    }else{
        [SSWL_PublicTool showAlertToViewController:self alertControllerTitle:@"复制失败" alertControllerMessage:nil alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:^(UIAlertAction * _Nonnull action) {
            
        } reportHandler:nil completion:^{
            
        }];
    }
    
}

- (void)doShareWithMessageName:(NSString *)name param:(NSString *)param{
    Weak_Self;
    self.infoContextDict = [NSDictionary new];
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].giftId = param;
    [self getShareContextCompletion:^(BOOL isSuccess,  id _Nullable dict) {
        isSuccess = YES;
        if (isSuccess) {
            weakSelf.infoContextDict = dict[@"data"];
            [weakSelf sendMessageToApplicationWithInfo:weakSelf.infoContextDict];
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
}


/**
 * 事件监听
 */
- (void)statisticsAllEventWithMessageName:(NSString *)messageName Param:(NSString *)param{

    SYLog(@"%@", param);
}


/*处理签名*/
- (void)sendDataForPrama:(NSDictionary *)param messageName:(NSString *)name{
    NSString *jsString = [NSString string];
//    NSArray *paramArr = [NSArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];
    NSString *string = [NSString stringWithFormat:@"%@", dict[@"sign"]];
    if (string.length > 0) {
        [dict removeObjectForKey:@"sign"];
    }
    //        [dict setObject:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
    //        [dict setValue:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:dict];
    jsString = [NSString stringWithFormat:@"getiOSSign('%@')", sign];
    
//    paramArr = [param allValues];
    SYLog(@"-----------------dict:%@------------", dict);
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        SYLog(@"----------%@____%@", result, error);
    }];
    
    
}




/**
 * 获取分享内容,发送通知

 @param info 分享内容
 */
- (void)sendMessageToApplicationWithInfo:(NSDictionary *)info{
    NSDictionary *context = @{
                              @"share_image"     :   @"https://systatic.shangshiwl.com/game/share/1711/281525048613.jpg",
                              @"content"         :   @"测试分享的内容666",
                              @"title"           :   @"测试分享的标题666",
                              @"link"            :  @"https://www.shangshiwl.com",
                              };
    UIViewController *vc = self;

    /**
     * 注册通知,退出时发送通知
     */
    NSDictionary *dic = @{
                          @"isShare"        : @YES,
                          @"viewController" : vc,
                          @"context"        : context,
                          };
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center postNotificationName:SSWL_ShareGiftInfo object:@"shareInfo" userInfo:dic];
}

- (void)ifShareIsSuccess{
    SYLog(@"分享成功-------回调---------前端");
    NSString *jsString = [NSString stringWithFormat:@"shareCallback('%@','%@')", @"1", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].giftId];
    
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        SYLog(@"----------%@______________%@", result, error);
    }];
}


/*不要了*/
- (void)sendDataForPrama:(NSDictionary *)param{
    NSString *jsString = [NSString string];
//    NSArray *paramArr = [NSArray array];
//    paramArr = [param allValues];

//    NSMutableArray *paramArr = [NSMutableArray new];
//    SYLog(@"--------------param:%@", param);
    if (param[@"ios"]) {
        SYLog(@"第一次拿token");
        NSDictionary *dic = @{
                          @"token" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          };
        NSString *sign = [SSWL_PublicTool makeSignStringWithParams:dic];

        jsString = [NSString stringWithFormat:@"getiOSToken('%@','%@')", sign, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];

    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];
//        [dict setObject:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
//        [dict setValue:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
        NSString *sign = [SSWL_PublicTool makeSignStringWithParams:dict];
        jsString = [NSString stringWithFormat:@"getiOSSign('%@')", sign];
        
//        paramArr = [param allValues];
        SYLog(@"-----------------dict:%@------------", dict);
        
    }

    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        SYLog(@"----------%@____%@", result, error);
    }];

}





// 回到应用判断[SSWL_BasiceInfo sharedSSWL_BasiceInfo].isShareSuccess是否是yes
- (void)applicationDidBecomeActive:(UIApplication *)application {
    SYLog(@"回来主进程");
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isShareSuccess) {
        [self ifShareIsSuccess];
        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isShareSuccess = NO;
    }
    
}



/*没用了*/
- (void)clearData{
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    //// Date from
    
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    //// Execute
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
        // Done
        
    }];
}


- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTap:)];
        [_errorView addGestureRecognizer:tap];
    }
    return _errorView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
