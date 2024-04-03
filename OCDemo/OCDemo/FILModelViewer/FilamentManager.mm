//
//  FilamentManager.m
//  OCDemo
//
//  Created by EZen on 2024/03/15.
//

#import "FILModelView.h"
#import "FilamentManager.h"

#include <filament/Engine.h>
#include <filament/Scene.h>
#include <filament/Skybox.h>
#include <utils/EntityManager.h>
#include <gltfio/Animator.h>
#include <ktxreader/Ktx1Reader.h>
#include <viewer/AutomationEngine.h>

#include <filament/IndirectLight.h>
#include <filament/LightManager.h>
#include <filament/RenderableManager.h>
#include <filament/Renderer.h>
#include <filament/TransformManager.h>
#include <filament/View.h>

#include <utils/EntityManager.h>

using namespace filament;
using namespace utils;
using namespace ktxreader;


@interface FilamentManager ()

@property (nonatomic, strong, nullable, readwrite) FILModelView *modelView;
@property (nonatomic, assign) CGRect frameInContainer;
@property (nonatomic, weak, nullable) UIView *containerView;

@end

@implementation FilamentManager {
    
    CADisplayLink* _displayLink;
    CFTimeInterval _startTime;
    
    viewer::AutomationEngine* _automation;
    UILabel* _toastLabel;

    //Texture* _skyboxTexture;
    Skybox* _skybox;
    Texture* _iblTexture;
    IndirectLight* _indirectLight;
    Entity _sun;

    //UITapGestureRecognizer* _doubleTapRecognizer;
}

- (instancetype)initWithRect:(CGRect)rect superView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.frameInContainer = rect;
        self.containerView = view;
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Observe lifecycle notifications to prevent us from rendering in the background.
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(appWillResignActive:)
                                               name: UIApplicationWillResignActiveNotification
                                             object: nil];
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(appDidBecomeActive:)
                                               name: UIApplicationDidBecomeActiveNotification
                                             object: nil];
    
    self.modelView = [[FILModelView alloc] initWithFrame: self.frameInContainer];
    [self.containerView addSubview:self.modelView];
    
    [self createLights];
    _automation = viewer::AutomationEngine::createDefault();
    
    //_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
    //                                                               action: @selector(reloadModel)];
    //_doubleTapRecognizer.numberOfTapsRequired = 2;
    //[self.modelView addGestureRecognizer: _doubleTapRecognizer];
}

#pragma mark - glb

- (void)setGLBModelFilePath:(NSString *)glbFilePath callback:(void(^_Nullable)(void))callback
{
    if (!glbFilePath) return;
    NSData *buffer = [NSData dataWithContentsOfFile: glbFilePath];
    
    [self.modelView loadModelGlb: buffer callback: ^{
        callback();
    }];
    
    [self.modelView transformToUnitCube];
}

- (void)createDefaultRenderables 
{
    [self.modelView transformToUnitCube];
}

- (void)createLights 
{
    // Load Skybox.
    //NSString* skyboxPath = [[NSBundle mainBundle] pathForResource:@"default_env_skybox" ofType:@"ktx"];
    //assert(skyboxPath.length > 0);
    //NSData* skyboxBuffer = [NSData dataWithContentsOfFile:skyboxPath];
    
    //image::Ktx1Bundle* skyboxBundle = new image::Ktx1Bundle(static_cast<const uint8_t*>(skyboxBuffer.bytes), static_cast<uint32_t>(skyboxBuffer.length));
    //_skyboxTexture = Ktx1Reader::createTexture(self.modelView.engine, skyboxBundle, false);
    _skybox = filament::Skybox::Builder()
        //.environment(_skyboxTexture)
        //.color(math::float4(0.0f, 0.0f, 0.0f, 0.0f))
        .color(math::float4 {})
        .build(*self.modelView.engine);
    self.modelView.scene->setSkybox(_skybox);
    
    // Load IBL.
    NSString* iblPath = [[NSBundle mainBundle] pathForResource:@"default_env_ibl" ofType:@"ktx"];
    assert(iblPath.length > 0);
    NSData* iblBuffer = [NSData dataWithContentsOfFile:iblPath];
    
    image::Ktx1Bundle* iblBundle = new image::Ktx1Bundle(static_cast<const uint8_t*>(iblBuffer.bytes), static_cast<uint32_t>(iblBuffer.length));
    math::float3 harmonics[9];
    iblBundle->getSphericalHarmonics(harmonics);
    _iblTexture = Ktx1Reader::createTexture(self.modelView.engine, iblBundle, false);
    _indirectLight = IndirectLight::Builder()
                             .reflections(_iblTexture)
                             .irradiance(3, harmonics)
                             .intensity(30000.0f)
                             .build(*self.modelView.engine);
    self.modelView.scene->setIndirectLight(_indirectLight);
    
    // Always add a direct light source since it is required for shadowing.
    _sun = EntityManager::get().create();
    LightManager::Builder(LightManager::Type::DIRECTIONAL)
            .color(Color::cct(6500.0f))
            .intensity(100000.0f)
            .direction(math::float3(0.0f, -1.0f, 0.0f))
            .castShadows(true)
            .build(*self.modelView.engine, _sun);
    self.modelView.scene->addEntity(_sun);
    self.modelView.scene->setSkybox(NULL);
}


- (void)render 
{
    //NSLog(@"%s", __func__);
    auto* animator = self.modelView.animator;
    if (animator) {
        if (animator->getAnimationCount() > 0) {
            CFTimeInterval elapsedTime = CACurrentMediaTime() - _startTime;
            animator->applyAnimation(0, static_cast<float>(elapsedTime));
        }
        animator->updateBoneMatrices();
    }
    [self.modelView render];
}

//- (void)reloadModel 
//{
//    [self.modelView destroyModel];
//    [self createDefaultRenderables];
//}

#pragma mark -- Life Circle

- (void)appWillResignActive:(NSNotification*)notification {
    [self stopDisplayLink];
}

- (void)appDidBecomeActive:(NSNotification*)notification {
    [self startDisplayLink];
}

- (void)viewWillAppear:(BOOL)animated {
    [self startDisplayLink];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopDisplayLink];
}

#pragma mark - Timer

- (void)startDisplayLink {
    [self stopDisplayLink];
    
    // Call our render method 60 times a second.
    _startTime = CACurrentMediaTime();
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(render)];
    _displayLink.preferredFramesPerSecond = 60;
    [_displayLink addToRunLoop: NSRunLoop.currentRunLoop
                       forMode: NSDefaultRunLoopMode];
}

- (void)stopDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
}


- (void)dealloc {
    
    NSLog(@"%s", __func__);
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self stopDisplayLink];
    delete _automation;
    
    self.modelView.engine->destroy(_indirectLight);
    self.modelView.engine->destroy(_iblTexture);
    self.modelView.engine->destroy(_skybox);
    //self.modelView.engine->destroy(_skyboxTexture);
    if (!_sun.isNull()) {
        self.modelView.scene->remove(_sun);
        self.modelView.engine->destroy(_sun);
    }
    
    //self.modelView = nil;
}

@end
