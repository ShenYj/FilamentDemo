//
//  FilamentManager.h
//  OCDemo
//
//  Created by EZen on 2024/03/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FILModelView;
@interface FilamentManager : NSObject

@property (nonatomic, strong, readonly) FILModelView *modelView;

- (instancetype)initWithRect:(CGRect)rect superView:(UIView *)view;
- (void)setGLBModelFilePath:(NSString *)glbFilePath callback:(void(^_Nullable)(void))callback;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
