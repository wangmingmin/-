//
//  FirstViewController.m
//  iBeaconClean
//
//  Created by 123 on 16/3/21.
//  Copyright © 2016年 star. All rights reserved.
//

#import "FirstViewController.h"
@import CoreBluetooth;
@import CoreLocation;

@interface FirstViewController ()<CLLocationManagerDelegate,CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *beaconLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (strong,nonatomic) CBCentralManager *centralManager;//中心设备管理器
@property (strong, nonatomic) CLBeaconRegion * beaconRegion;
@property (strong, nonatomic) CLLocationManager * trackLocationManager;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.trackLocationManager = [[CLLocationManager alloc] init];
    self.trackLocationManager.delegate = self;
    [self initRegion];
}

- (IBAction)startCentralManager:(UIButton *)sender {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

//中心服务器状态更新后
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            //扫描外围设备
            //            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            [self.centralManager stopScan];
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为中心设备.");
            break;
    }
}

/**
 *  发现外围设备
 *
 *  @param central           中心设备
 *  @param peripheral        外围设备
 *  @param advertisementData 特征数据
 *  @param RSSI              信号质量（信号强度）
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备...%@",advertisementData);
    //停止扫描
    [self.centralManager stopScan];
    //连接外围设备
    //其它关于CoreBluetooth查看CoreBluetoothTest demo
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initRegion
{
    //用来初始化这个实例的的uuid字符串必须和基站的uuid字符串是一样的，要不互相找不见,终端输入uuidgen可随机获取一个
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
    NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:@"2200FFA0-1CE6-4E5E-B89B-3ED12B6D129E"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.star.iBeacon"];
    [self.trackLocationManager startMonitoringForRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.trackLocationManager startRangingBeaconsInRegion:self.beaconRegion];
    /*
     当你接收到基站信号的时候这个方法就开始执行（当然你要离基站足够近）。然后调用locationManager的startRagingBeaconsInRegion方法，病传入我们之前定义好的beaconRegion属性。
     */
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.trackLocationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconLabel.text = @"No";
    /*
     在离开这个区域的时候就停止执行，调用locationManager的stopRagingBeaconsInRegion。
     */
}

//当你从足够远（10～20米）的地方想基站的方向走的时候，didEnterRange 和 didRangeBeacons方法就会被调用，这时就可以从方法中传入的beacon数组中取出值来现实在界面上。
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"beacon count = %lu",beacons.count);
    if (beacons.count <= 0) {
        NSLog(@"没有beacon");
        return;
    }
    
    CLBeacon * beacon = beacons.lastObject;
    
    self.beaconLabel.text = @"Yes";
    self.uuidLabel.text = beacon.proximityUUID?beacon.proximityUUID.UUIDString:@"no proximityUUID";
    self.majorLabel.text = beacon.major?beacon.major.stringValue:@"no major";
    self.minorLabel.text = beacon.minor?beacon.minor.stringValue:@"no minor";
    self.accuracyLabel.text = beacon.accuracy?[NSString stringWithFormat:@"%f",beacon.accuracy]:@"no accuracy";
    
    /*之后的代码都只是从beacon中取出数据来现实在界面上，比如UUID，major，minor，accuracy和RSSI。这些值会随着接收机和基站的距离不同以及基站的设置不同而一直改变。尤其accuracy和RSSI都是beacon用来现实距离的。其中proximity会显示四个值：Unknown、Immediate、Near和Far。Immediate是半米以内，Near远一些，Far更远。RSSI是信号强度。
     */
    if (beacon.proximity) {
        switch (beacon.proximity) {
            case CLProximityUnknown:
                self.distanceLabel.text = @"Unknown proximity";
                break;
            case CLProximityImmediate:
                self.distanceLabel.text = @"Immediate";
                break;
            case CLProximityNear:
                self.distanceLabel.text = @"Near";
                break;
            case CLProximityFar:
                self.distanceLabel.text = @"Far";
                break;

            default:
                NSLog(@"default of switch-case");
                break;
        }
    }
    self.rssiLabel.text = beacon.rssi?[NSString stringWithFormat:@"rssi = %lu",beacon.rssi]:@"No rssi";
    
}
@end
