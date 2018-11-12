//
//  SSYRedpacketDJSView.m
//  Drugdisc
//
//  Created by huangliwen on 2018/11/6.
//  Copyright © 2018年 Drugdisc. All rights reserved.
//

#import "SSYRedpacketDJSView.h"
#define kCoinCountKey   100     //总数
// 弱引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
@interface SSYRedpacketDJSView()<CAAnimationDelegate>{
    NSMutableArray  *_coinTagsArr;  //存放生成的所有红包对应的tag值
}
@property (strong, nonatomic) UIView *viewDJS;
@property (strong, nonatomic) UILabel *labDJS;//倒计时
@property (strong, nonatomic) UIView *viewRedyu;//红包雨
@property (strong, nonatomic) UIButton *btnTotal;
@property (strong, nonatomic) UILabel *labDanciAdd;
@property(strong,nonatomic)UILabel *labRedyuDjs;//红包雨倒计时
@property (strong, nonatomic) UIView *viewRedpacketDown;//下雨动画
@property (strong, nonatomic) UIImageView *imgBox;

@end
@implementation SSYRedpacketDJSView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        _viewDJS=[[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-330)/2-4, (SCREEN_HEIGHT-305)/2-20, 330, 305)];
        UIImage *img=[UIImage imageNamed:@"activity_daojishi"];
        UIImageView *imgDJS=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        [imgDJS setImage:img];
        imgDJS.contentMode=UIViewContentModeScaleAspectFit;
        [_viewDJS addSubview:imgDJS];
        _labDJS=[[UILabel alloc] initWithFrame:CGRectMake(136, 197, 80, 70)];
        [_labDJS setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:40]];
        [_labDJS setTextColor:[UIColor whiteColor]];
        _labDJS.textAlignment=NSTextAlignmentCenter;
        [_viewDJS addSubview:_labDJS];
        [self addSubview:_viewDJS];
        
        //红包雨
        _viewRedyu=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [_viewRedyu setHidden:YES];
        [self addSubview:_viewRedyu];
        _labRedyuDjs=[[UILabel alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 20)];
        [_labRedyuDjs setTextColor:[UIColor whiteColor]];
        [_labRedyuDjs setFont:[UIFont systemFontOfSize:25]];
        _labRedyuDjs.textAlignment=NSTextAlignmentCenter;
        [_viewRedyu addSubview:_labRedyuDjs];
        UILabel *labtishi=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-165)/2, SCREEN_HEIGHT-38, 165, 18)];
        [labtishi setTextColor:[UIColor whiteColor]];
        [labtishi setFont:[UIFont systemFontOfSize:13]];
        [_viewRedyu addSubview:labtishi];
        _btnTotal=[[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, SCREEN_HEIGHT-78, 100, 30)];
        [_btnTotal setBackgroundImage:[UIImage imageNamed:@"red_bottom_btn"] forState:0];
        [_btnTotal setTitle:@"¥ 0.0" forState:0];
        [_btnTotal setTitleColor:[UIColor whiteColor] forState:0];
        [_btnTotal.titleLabel setFont:[UIFont fontWithName:@"STHeitiJ-Medium" size:17]];
        [_btnTotal setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [_btnTotal setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        [_viewRedyu addSubview:_btnTotal];
        _imgBox=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-131)/2, SCREEN_HEIGHT-196, 131, 105)];
        [_imgBox setImage:[UIImage imageNamed:@"red_box"]];
        [_viewRedyu addSubview:_imgBox];
        _labDanciAdd=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_imgBox.frame), SCREEN_HEIGHT-115, 131, 17)];
        [_labDanciAdd setTextColor:[UIColor whiteColor]];
        [_labDanciAdd setFont:[UIFont systemFontOfSize:14]];
        _labDanciAdd.textAlignment=NSTextAlignmentCenter;
        [_viewRedyu addSubview:_labDanciAdd];
        
        //点击事件开始动画
        _viewRedpacketDown=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-206)];
        _viewRedpacketDown.clipsToBounds=YES;
        _viewRedpacketDown.userInteractionEnabled=YES;
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onQRedpacket:)];
        [_viewRedpacketDown addGestureRecognizer:singleTap];
        [_viewRedyu addSubview:_viewRedpacketDown];
        [self startTime];
    }
    return self;
}

- (void)startTime
{
    __block int timeout = 10;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(_timer, ^{
        if ( timeout <= 0 )
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.viewDJS setHidden:YES];
                [weakSelf.viewRedyu setHidden:NO];
                [weakSelf getAction];
            });
        }
        else
        {
            NSString * titleStr = [NSString stringWithFormat:@"%d",timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.labDJS setText:titleStr];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
-(void)showView{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

//统计数量的变量
static int coinCount = 0;
- (void)getAction
{
    //初始化金币生成的数量
    coinCount = 0;
    for (int i = 0; i<kCoinCountKey; i++) {
        int sjs = arc4random() % 10;
        if(sjs%2==0){
            //金币出现
            //延迟调用函数
            [self performSelector:@selector(initCoinViewWithInt:) withObject:[NSNumber numberWithInt:i] afterDelay:i * 0.2];
        }else if (sjs%3==0){
            //红包出现
            [self performSelector:@selector(initRedViewWithInt:) withObject:[NSNumber numberWithInt:i] afterDelay:i * 0.3];
        }else{
            //星星
            [self performSelector:@selector(initXingViewWithInt:) withObject:[NSNumber numberWithInt:i] afterDelay:i * 0.1];
        }
    }
}

- (void)initCoinViewWithInt:(NSNumber *)i
{
    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"red_jinbi_%d",[i intValue] % 2 + 1]];
    CALayer *coin=[CALayer layer];
    int index= [i intValue] + 1;
    coin.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    coin.contents=(id)image.CGImage;
    [coin setValue:[NSString stringWithFormat:@"%d",index] forKey:@"name"];
    //每生产一个金币,就把该金币对应的tag加入到数组中,用于判断当金币结束动画时和福袋交换层次关系,并从视图上移除
    [_coinTagsArr addObject:[NSNumber numberWithInt:index]];
    [_viewRedpacketDown.layer addSublayer:coin];
    
    [self setAnimationWithLayer:coin type:0];
}
//红包
- (void)initRedViewWithInt:(NSNumber *)i
{
    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"red_pack_%d",[i intValue] % 2 + 1]];
    CALayer *coin=[CALayer layer];
    int index= [i intValue] + 1000;
    coin.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    coin.contents=(id)image.CGImage;
    [coin setValue:[NSString stringWithFormat:@"%d",index] forKey:@"name"];
    //每生产一个金币,就把该金币对应的tag加入到数组中,用于判断当金币结束动画时和福袋交换层次关系,并从视图上移除
    [_coinTagsArr addObject:[NSNumber numberWithInt:index]];
    [_viewRedpacketDown.layer addSublayer:coin];
    
    [self setAnimationWithLayer:coin type:1];
}
//星星
- (void)initXingViewWithInt:(NSNumber *)i
{
    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"red_xing_%d",[i intValue] % 2 + 1]];
    CALayer *coin=[CALayer layer];
    coin.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    coin.contents=(id)image.CGImage;
    int index=[i intValue] + 10000;
    [coin setValue:[NSString stringWithFormat:@"%d",index] forKey:@"name"];
    //每生产一个金币,就把该金币对应的tag加入到数组中,用于判断当金币结束动画时和福袋交换层次关系,并从视图上移除
    [_coinTagsArr addObject:[NSNumber numberWithInt:index]];
    
    [_viewRedpacketDown.layer addSublayer:coin];
    
    [self setAnimationWithLayer:coin type:0];
}
-(void)onQRedpacket:(UITapGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:self];
    for (int i = 0 ; i < _viewRedpacketDown.layer.sublayers.count ; i ++)
    {
        CALayer * layer = _viewRedpacketDown.layer.sublayers[i];
        if ([[layer presentationLayer] hitTest:point] != nil)
        {
            NSLog(@"%d",i);
            //点击到了
            NSInteger index=[[layer valueForKey:@"name"] integerValue];
            if (index<10000) {
                NSLog(@"点击了红包");
                [self bagShakeAnimation];
                self.labDanciAdd.text=[NSString stringWithFormat:@"+%ld",index];
                [self.btnTotal setTitle:[NSString stringWithFormat:@"¥ %ld",index] forState:0];
            }
        }
    }
}

- (void)setAnimationWithLayer:(CALayer *)coin type:(int)type
{
    CGFloat duration = 3.6f;
    CGMutablePathRef path = CGPathCreateMutable();
    int fromX       = (arc4random() % 526)-150;     //起始位置:x轴上随机生成一个位置
    int fromY       = -arc4random() % 30;//arc4random() % 400; //起始位置:生成位于福袋上方的随机一个y坐标
    if (type==1) {
        fromX=MAX(0, fromX);
        fromX=MIN(fromX, SCREEN_WIDTH-50);
    }
    CGFloat positionX   = fromX+200;    //终点x
    CGFloat positionY   = 500;    //终点y
    
    //动画的起始位置
    CGPathMoveToPoint(path, NULL, fromX, fromY);
    CGPathAddLineToPoint(path, nil, positionX, positionY);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    CFRelease(path);
    path = nil;
    //动画组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.repeatDuration=60;//动画持续时间
    group.animations = @[animation];
    
    [coin addAnimation:group forKey:@"position and transform"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        
        //动画完成后把金币和数组对应位置上的tag移除
        UIView *coinView = (UIView *)[self viewWithTag:[[_coinTagsArr firstObject] intValue]];
        
        [coinView removeFromSuperview];
        [_coinTagsArr removeObjectAtIndex:0];
        
        //全部金币完成动画后执行的动作
        if (++coinCount == kCoinCountKey) {
            
            [self bagShakeAnimation];
            
        }
    }
}

//宝箱晃动动画
- (void)bagShakeAnimation
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:- 0.2];
    shake.toValue   = [NSNumber numberWithFloat:+ 0.2];
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = 4;
    
    [_imgBox.layer addAnimation:shake forKey:@"bagShakeAnimation"];
}
@end
