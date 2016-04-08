//
//  ViewController.m
//  gamekieTest
//
//  Created by 123 on 16/2/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<GKPeerPickerControllerDelegate,GKSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property (weak, nonatomic) IBOutlet UIButton *connect;
@property (weak, nonatomic) IBOutlet UIButton *disconnect;
@property (strong, nonatomic) GKSession *currentSession;
@property (strong, nonatomic) GKPeerPickerController * picker;
@end

@implementation ViewController
- (IBAction)btnSend:(UIButton *)sender {
    NSLog(@"sending....");
    NSString * str = [NSString stringWithString:self.txtMessage.text];
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self mySendDataToPeers:data];
}

- (IBAction)btnConnect:(UIButton *)sender {
    NSLog(@"connecting....");
    self.picker = [[GKPeerPickerController alloc] init];
    self.picker.delegate = self;
    self.picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    //connectionTypesMask属性指出用户可以选择的连接类型，包括两种类 型：GKPeerPickerConnectionTypeNearby和GKPeerPickerConnectionTypeOnline。对于蓝牙 通信，使用GKPeerPickerConnectionTypeNearby常量，GKPeerPickerConnectionTypeOnline 常量表示基
    self.connect.hidden = YES;
    self.disconnect.hidden = NO;
    [self.picker show];
}

//如果要从一个设备断开连接，使用来自GKSession对象的disconnectFromAllPeers方法
- (IBAction)btnDisconnect:(UIButton *)sender {
    NSLog(@"disconnecting....");
    [self.currentSession disconnectFromAllPeers];
    self.currentSession = nil;
    self.connect.hidden = NO;
    self.disconnect.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.disconnect.hidden = YES;
}

//当建立一个连接时，你可能想要立即向对方发送数据。为了向连接的蓝牙设备发送数据，需要使用到GKSession对象的sendDataToAllPeers:方法，你发送的数据是通过NSData对象 传输的，因此你可以自定义你的应用程序协议和发送的数据类型(如二进制数据)，mySendDataToPeers:方法的定义如下：
-(void) mySendDataToPeers:(NSData *) data
{
    if(self.currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

//当设备接收到数据时，调用receiveData:fromPeer:inSession:context:方法
-(void) receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context {
    
    NSString * str =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Data received" message:str
                                                  delegate:self
                                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//用户选择并连接到其中一个蓝牙设备时，调用peerPickerController:didConnectPeer:toSession:方法
-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    [picker dismiss];
}

-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate =nil;
    [self.connect setHidden:NO];
    [self.disconnect setHidden:YES];
}

//连接设备或断开连接时，调用session:peer:didChangeState:方法
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"yeah, connect already!");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"woo! disconnect!");
            self.currentSession = nil;
            self.connect.hidden = NO;
            self.disconnect.hidden  = YES;
            break;
            
        default:
            self.currentSession = nil;
            self.connect.hidden = NO;
            self.disconnect.hidden  = YES;
            break;
    }
}
@end
