//
//  NextViewController.m
//  OCDemo
//
//  Created by EZen on 2022/3/18.
//

#import "NextViewController.h"
#import "FilamentManager.h"

@interface NextViewController ()

@property (nonatomic, strong) FilamentManager *filamentManager;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.backgroundImageView];
    
    //CGFloat originalY = (self.view.bounds.size.height - self.view.bounds.size.width) * 0.5;
    //CGRect renderRect = CGRectMake(0, originalY, self.view.bounds.size.width, self.view.bounds.size.width);
    self.filamentManager = [[FilamentManager alloc] initWithRect: self.view.bounds superView:self.view];
    
    NSString *glbFilePath = [[NSBundle mainBundle] pathForResource:@"c0ba1ab7e9104b288859389fe6d774ba_1057.glb" ofType:nil];
    NSLog(@"glbFilePath: %@", glbFilePath);
    
    [self.filamentManager setGLBModelFilePath:glbFilePath callback:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.filamentManager viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.filamentManager viewWillDisappear:animated];
}


- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - lazy

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.image = [UIImage imageNamed:@"model_page_bg"];
    }
    return _backgroundImageView;
}

@end
