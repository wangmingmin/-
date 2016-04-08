//
//  SecondViewController.m
//  iBeaconClean
//
//  Created by 123 on 16/3/21.
//  Copyright © 2016年 star. All rights reserved.
//

#import "SecondViewController.h"
@import CoreBluetooth;
@import CoreLocation;

@interface SecondViewController ()<CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UIButton *transmitButton;

@property (strong, nonatomic) CLBeaconRegion * beaconRegion;//用来设置基站需要的 proximityUUID，major 和 minor的信息。
@property (strong, nonatomic) NSDictionary * beaconPeripheralData;//用来获取外设的数据
@property (strong, nonatomic) CBPeripheralManager * peripheralManager;//用来开启基站的数据传输
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initBeacon];
    [self setLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initBeacon
{
    //用来初始化这个实例的的uuid字符串必须和接收机的uuid字符串是一样的，要不互相找不见,终端输入uuidgen可随机获取一个
    /*
     或者代码
     NSString * uuid = [[NSUUID UUID] UUIDString];//kCharacteristicUUID每次不一样，可用于特征的UUID
     
     UIDevice *device = [UIDevice currentDevice];//创建设备对象
     NSUUID *UUID = [device identifierForVendor];
     NSString * deviceID = [UUID UUIDString];
     NSLog(@"deviceID before= %@",deviceID);//kServiceUUID唯一，可用于服务的UUID
     deviceID = [deviceID stringByReplacingOccurrencesOfString:@"-" withString:@""];
     NSLog(@"deviceID = %@,,,,,, uuid = %@",deviceID,uuid);
     */
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:@"2200FFA0-1CE6-4E5E-B89B-3ED12B6D129E"] major:1 minor:1 identifier:@"com.star.iBeacon"];
}

-(void)setLabels
{
    self.uuidLabel.text = self.beaconRegion.proximityUUID.UUIDString;
    self.majorLabel.text = self.beaconRegion.major.stringValue;
    self.minorLabel.text = self.beaconRegion.minor.stringValue;
    self.identityLabel.text = self.beaconRegion.identifier;
}

- (IBAction)transmit:(UIButton *)sender {
    //在用户点击了传输按钮之后开始使用设备的蓝牙外设发出信号
    //首先通过我们设定的beaconRegion属性获得相关的外设数据。这个数据是NSDictionary类型的。
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:@150];//此处设置的参数还需要斟酌
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    /*
     // 初始的时候是未知的（刚刚创建的时候）
     CBCentralManagerStateUnknown = 0,
     //正在重置状态
     CBCentralManagerStateResetting,
     //设备不支持的状态
     CBCentralManagerStateUnsupported,
     // 设备未授权状态
     CBCentralManagerStateUnauthorized,
     //设备关闭状态
     CBCentralManagerStatePoweredOff,
     // 设备开启状态 -- 可用状态
     CBCentralManagerStatePoweredOn,
     */
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"powerOn");
            [self.peripheralManager startAdvertising:self.beaconPeripheralData];
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"powerOff");
            [self.peripheralManager stopAdvertising];
            break;
  
        default:
            break;
    }
}
@end
