//
//  ViewController.m
//  OCDemo
//
//  Created by EZen on 2022/3/18.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(test:)];
    
}

- (void)test:(id)sender {
    
    UIViewController *vc = [[NextViewController alloc] init];
    //UIViewController *vc = [[DemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
