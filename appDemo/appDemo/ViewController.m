//
//  ViewController.m
//  appDemo
//
//  Created by hanyutong on 2018/7/17.
//  Copyright © 2018年 Hanne. All rights reserved.
//

#import "ViewController.h"

#define Framework @"https://github.com/xingfudeyutian/With-the-framework-dynamic-updates/raw/master/frameworkDemo.framework.zip"

@interface ViewController ()<NSURLSessionDataDelegate>

@property (nonatomic, assign)NSInteger totalSize;
@property (nonatomic, assign)NSInteger currentSize;
@property (nonatomic, strong) NSOutputStream * stream;
@property (nonatomic, strong) NSFileHandle * handle;
@property (nonatomic, strong) NSString * fullPath;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)download:(id)sender {


  NSURLSession * session= [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];


  NSURL *url = [NSURL URLWithString:Framework];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];


  NSURLSessionDataTask * downloadTask = [session dataTaskWithRequest:request];

  [downloadTask resume];

}
- (IBAction)click:(id)sender {

  NSLog(@"%@", NSHomeDirectory());
  UIViewController * vc =[self loadFrameworkNamed:@"frameworkDemo"];
  [self presentViewController:vc animated:YES completion:nil];

}

- (UIViewController *)loadFrameworkNamed:(NSString *)bundleName {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = nil;
  if ([paths count] != 0) {
    documentDirectory = [paths objectAtIndex:0];
  }

  NSFileManager *manager = [NSFileManager defaultManager];
  NSString *bundlePath = [documentDirectory stringByAppendingPathComponent:[bundleName stringByAppendingString:@".framework"]];

  // Check if new bundle exists
  if (![manager fileExistsAtPath:bundlePath]) {
    NSLog(@"No framework update");
    bundlePath = [[NSBundle mainBundle]
                  pathForResource:bundleName ofType:@"framework"];

    // Check if default bundle exists
    if (![manager fileExistsAtPath:bundlePath]) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oooops" message:@"Framework not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alertView show];
      return nil;
    }
  }

  // Load bundle
  NSError *error = nil;
  NSBundle *frameworkBundle = [NSBundle bundleWithPath:bundlePath];
  if (frameworkBundle && [frameworkBundle loadAndReturnError:&error]) {
    NSLog(@"Load framework successfully");
  }else {
    NSLog(@"Failed to load framework with err: %@",error);
    return nil;
  }

  // Load class
  Class PublicAPIClass = NSClassFromString(@"FrameWorkViewController");
  if (!PublicAPIClass) {
    NSLog(@"Unable to load class");
    return nil;
  }

  UIViewController *publicAPIObject = [PublicAPIClass new];
  return publicAPIObject;
}


-(void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler
  {
    self.totalSize = response.expectedContentLength;
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
    NSLog(@"%@",fullPath);

    self.stream = [[NSOutputStream alloc] initToFileAtPath:fullPath append:YES];
    [self.stream open];

    completionHandler(NSURLSessionResponseAllow);
  }

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data
  {
    [self.stream write:data.bytes maxLength:data.length];
    self.currentSize += data.length;
    NSLog(@"%f",1.0*self.currentSize/self.totalSize);
  }

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
  {
    [self.stream close];
    self.stream = nil;
    self.totalSize = 0;
    self.currentSize = 0;
    //下载完成后 自己在文件夹双击解压缩！！！！
    //解压缩没有写在代码里，双击解压之后，才能调用framework里的类
  }


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
