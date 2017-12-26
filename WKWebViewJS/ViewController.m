//
//  ViewController.m
//  WKWebViewJS
//
//  Created by Ios_Developer on 2017/12/26.
//  Copyright © 2017年 hai. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic ,strong)WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   [self.view addSubview:self.webView];
    
    //kvo监听
    [_webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

#pragma mark  =====  loadSubViews  =====
-(WKWebView*)webView
{
    if (!_webView)
    {
        WKWebViewConfiguration *webConfig = [WKWebViewConfiguration new];
        webConfig.userContentController = [[WKUserContentController alloc] init];
        
        // 注入JS对象名称 @"haiJSname"，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
        [webConfig.userContentController addScriptMessageHandler:self name:@"haiJSname"];
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webConfig];
        _webView.navigationDelegate = self;//监听加载进度
        _webView.UIDelegate = self;//与JS的alert、confirm、prompt交互 使用OC原生的提示控件，而非js的
        NSString *htmlStr = [[NSBundle mainBundle] pathForResource:@"HaiWKWebView" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:htmlStr];
        [_webView loadHTMLString:[[NSString alloc] initWithContentsOfFile:htmlStr encoding:NSUTF8StringEncoding error:nil] baseURL:url];
    }
    return _webView;
}

#pragma mark  ===== kvo action  =====
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"])
    {
        NSLog(@"loading");
        
    } else if ([keyPath isEqualToString:@"title"])
    {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        NSLog(@"progress: %f", self.webView.estimatedProgress);
    }
    
    // 加载完成
    if (!self.webView.loading)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            NSLog(@"加载完成");
        }];
    }
}

#pragma mark
#pragma mark =====  WKScriptMessageHandler js接收处理 =====
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"haiJSname"])
    {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        //do something
        NSLog(@"%@", message.body);
    }
}
#pragma mark
#pragma mark =====  WKUIDelegate  与JS的alert、confirm、prompt交互 使用OC原生的提示控件，而非js的 =====
//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"显示OC原生提示框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"alert message:%@",message);
}
//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:@"调用OC原生的confirm提示框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"confirm message:%@", message);
    
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:@"调用OC原生输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark
#pragma mark =====  WKNavigationDelegate  =====
////开始加载时调用
//-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
////当内容开始返回时调用
//-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
//{
//
//}
////页面加载完成之后调用
//-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
//{
//
//}
//// 页面加载失败时调用
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 接收到服务器跳转请求之后调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//
//}
//// 在发送请求之前，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//
//}

-(void)dealloc
{
    [_webView removeObserver:self forKeyPath:@"loading" context:nil];
    [_webView removeObserver:self forKeyPath:@"title" context:nil];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}
@end
