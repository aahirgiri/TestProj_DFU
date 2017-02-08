//
//  ViewController.m
//  DFU Test
//
//  Created by Aahir Giri on 06/02/17.
//  Copyright © 2017 Aahir Giri. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "YokyTag.h"
#import "User.h"
#import "ListTableViewCell.h"
#import "BleWorker.h"
#import "iOSDFULibrary-Swift.h"

@import CoreLocation;
@import CoreBluetooth;
@import QuartzCore;

@interface ViewController ()
@property (nonatomic,strong) CBCentralManager *cb;
@property NSMutableArray *bleWork;
@property CBUUID *S_YOKY,*S_DFU,*C_YOKY_CMD,*C_YOKY_NOTIFY,*C_YOKY_OWNER,*C_DFUPacket,*C_DFUControl,*C_DFUVersion;
@property NSMutableDictionary *numAlerts,*connectData;
@property (nonatomic,strong) User *user;
@property (nonatomic,strong) NSMutableArray *devices;
@property NSMutableArray *deviceList,*rssiList,*dataList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property int connect;
@property BOOL writeDfu;
@property CBPeripheral *selectedPeripheral;
@property BOOL isDfuInProgress;
@property NSURL *url;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user=[User sharedUser];
    [self initCBCentral];
    _deviceList = [NSMutableArray new];
    _rssiList = [NSMutableArray new];
    _dataList = [NSMutableArray new];
    _connect = 0;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)initCBCentral{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        if(_cb!=nil)return;
        _bleWork=[NSMutableArray new];
        _S_YOKY=[CBUUID UUIDWithString:@"c4215555-3739-ffea-0a7d-802211f186b8"];_S_DFU=[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"];
    
       // _C_DFUPacket=[CBUUID UUIDWithString:@"00001532-1212-EFDE-1523-785FEABCD123"];
        _C_DFUPacket=[CBUUID UUIDWithString:@"00001531-1212-EFDE-1523-785FEABCD123"];
        _C_DFUVersion=[CBUUID UUIDWithString:@"00001534-1212-EFDE-1523-785FEABCD123"];
        _cb=[[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
       // _cb=[[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:@"yokyTagCB"}];
        _connectData=[NSMutableDictionary new];
        NSMutableArray *pa=[NSMutableArray new];
    });
}

-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state{
    _devices=[NSMutableArray new];
    if(_user==nil)_user=[User sharedUser];
    NSArray *peripherals=state[CBCentralManagerRestoredStatePeripheralsKey];
    for(CBPeripheral *peripheral in peripherals){
        YokyTag *yt=[self getTagForPeripheral:peripheral];if(yt==nil){[_cb cancelPeripheralConnection:peripheral];return;}
        yt.peripheral=peripheral;[_devices addObject:peripheral];peripheral.delegate=self;yt.saveCfgFlag=1;
        if(peripheral.state!=CBPeripheralStateConnected){[_cb connectPeripheral:peripheral options:nil];continue;}
        CBService *service=[self getServiceFromPeripheral:peripheral forService:_S_YOKY];
        if(service==nil){[peripheral discoverServices:@[_S_YOKY]];continue;}
        CBCharacteristic *c=[self getCharacteristicFromService:service forCharacteristic:_C_DFUPacket];
        if(c==nil){[peripheral discoverCharacteristics:nil forService:service];continue;}
        if(!c.isNotifying){[peripheral setNotifyValue:YES forCharacteristic:c];continue;}
       // [self readOwner:peripheral];
        yt.llDate=[User formatDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSMutableArray *pa=[NSMutableArray new];for(int i=0;i<_user.yokyList.count;i++){
        YokyTag *yt=_user.yokyList[i];if(!yt.status&&yt.identifier)[pa addObject:yt.identifier];
    }
    if(pa.count>0){
        NSArray *ps=[_cb retrievePeripheralsWithIdentifiers:pa];
        if(ps.count)for(CBPeripheral *p in ps){
            [_cb connectPeripheral:p options:nil];
        }
    }
   [_user save];
}


-(void)startLeScan{
    if(_cb.state!=CBCentralManagerStatePoweredOn)return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_isDfuInProgress == YES) {
            NSLog(@"Scanning dfu");
            [_cb scanForPeripheralsWithServices:@[_S_DFU] options:nil];
        } else {
            [_cb scanForPeripheralsWithServices:@[_S_YOKY] options:nil];
        }
        [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(stopLeScan) userInfo:nil repeats:NO];
    });
}

-(void)stopLeScan{
    [_cb stopScan];
}



-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_cb.state!=CBCentralManagerStatePoweredOn){
        } else {
            for(int i=0;i<_user.yokyList.count;i++){
                YokyTag *yt=_user.yokyList[i];if(!yt||!yt.peripheral)continue;[_cb connectPeripheral:yt.peripheral options:nil];
            }
        }
        [self startLeScan];
    });
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"disconnected");
    [self onConnectionChange:NO withPeripheral:peripheral];
    _connect = 0;
    if(error) {
        NSLog(@"%@",error);
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Did discover");
        NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    //if(![localName isEqual:@"Yoky"])return;
        NSLog(@"Local name:%@",localName);
        NSDictionary *tdata=[advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    if(_isDfuInProgress == YES) {
        NSLog(@"discovered DFU peripherals");
        NSLog(@"%@",peripheral);
        if([_deviceList containsObject:peripheral]) {
            
        } else {
            [self.deviceList addObject:peripheral];
            [self.rssiList addObject: RSSI];
            [_tableView reloadData];
        }
    } else {
        NSLog(@"%@",peripheral);
        if([_deviceList containsObject:peripheral]) {
            
        } else {
            if (tdata) {
                [self.deviceList addObject:peripheral];
                [self.rssiList addObject: RSSI];
                [_tableView reloadData];
            }
        }
    }
   // });
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Connected");
        NSLog(@"%@",peripheral);
        _connect = 1;
        [self onConnectionChange:YES withPeripheral:peripheral];
        [peripheral setDelegate:self];
        [peripheral discoverServices:@[_S_DFU]];
        
        
        //yt.connected=[NSDate date];//if(yt.tagId==_tagUnderReset)//_tagUnderReset=-1;
    });
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"didDiscover Services");
        for(CBService *service in [peripheral services]){if([service.UUID isEqual:_S_DFU])[peripheral discoverCharacteristics:nil forService:service];}
    });
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"didDiscover Characteristics");
        if([service.UUID isEqual:_S_DFU]){
            CBCharacteristic *c=[self getCharacteristicFromService:service forCharacteristic:_C_DFUPacket];
            if(c!=nil){[peripheral setNotifyValue:YES forCharacteristic:c];}
        }
    });
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didUpdate Notification");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(error){[_cb cancelPeripheralConnection:peripheral];[_cb connectPeripheral:peripheral options:nil];}else [self writeOwner:peripheral];
        if(_isDfuInProgress == YES) {
            [self initiateDfu];
        }
    });
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)c error:(NSError *)error{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Did update value");
        if(error)return;
        if([c.UUID isEqual:_C_DFUPacket]){
            NSData *data=[c value];unsigned char d0;[data getBytes:&d0 length:1];
            [self analyseTagResponse:peripheral andRssi:[NSNumber numberWithInt:77]];
            NSLog(@"Data: %@",data);
        }
    });
}



-(void)analyseTagResponse:(CBPeripheral *)peripheral andRssi:(NSNumber *)RSSI{
   
    uint8_t first=01;NSMutableData *td=[NSMutableData dataWithBytes:&first length:1];
    uint8_t second=04; [td appendBytes:&second length:1];
    NSMutableDictionary *cd=[[NSMutableDictionary alloc] initWithObjectsAndKeys:td,@"data", nil];
    [_connectData setObject:cd forKey:[peripheral identifier]];
    _writeDfu = YES;
  
    if(_connect == 0) {
        NSLog(@"Connect");
        [_cb connectPeripheral:peripheral options:nil];
    }else {
        NSLog(@"Write");
        [self writeOwner:peripheral];

    }
//    }else{
//        NSLog(@"Else");
//        NSLog(@"%d",_connect);
//        
//    }
}
- (IBAction)scanAction:(id)sender {
    //[self initCBCentral];
    [self startLeScan];
}

-(void)writeOwner:(CBPeripheral *)peripheral{
    if(!_connectData)return;
    NSMutableDictionary *cd=[_connectData objectForKey:[peripheral identifier]];
    NSMutableData *d=[cd objectForKey:@"data"];
//    int tagId=[[cd objectForKey:@"tagId"] intValue];
    [self updateYokyTagId:1 andPeripheral:peripheral andData:d];
    [_connectData removeObjectForKey:[peripheral identifier]];
}

-(void)updateYokyTagId:(int)tagId andPeripheral:(CBPeripheral *)peripheral andData:(NSMutableData *)d{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YokyTag *yt=[self getTagForPeripheral:peripheral];
            [self addToBleWork:[[BleWorker alloc] initWithType:2 andData:d andPeripheral:peripheral andChar:_C_DFUPacket andTag:yt]];
    });
}

-(void)addToBleWork:(BleWorker *)b{
    [_bleWork addObject:b];[self processBleWork];
}

-(void)processBleWork{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            
            BleWorker *b=[_bleWork objectAtIndex:0];
            if(b.tag.tagId==255){[_bleWork removeObjectAtIndex:0];[self processBleWork];return;}
           
            if(b.peripheral==nil||b.peripheral.state!=CBPeripheralStateConnected){
                [_bleWork removeObjectAtIndex:0];
                [self processBleWork];return;
            }
            CBCharacteristic *c;
            c=[self getCharacteristicFromService:[self getServiceFromPeripheral:b.peripheral forService:_S_DFU] forCharacteristic:b.characteristic];
            if(c==nil){[_bleWork removeObjectAtIndex:0];
                [self processBleWork];
                return;}
            if(b.type==1){
                [b.peripheral readValueForCharacteristic:c];
            }else if(b.type==2){
                
                if ((c.properties & CBCharacteristicPropertyWrite) ||
                                                   (c.properties & CBCharacteristicPropertyWriteWithoutResponse))
                {
                    NSLog(@"Writing to peripheral");
                    NSLog(@"Peripheral: %@",b.peripheral);
                    NSLog(@"Data: %@",b.data);
                    NSLog(@"Characteristic: %@",c);
                [b.peripheral writeValue:b.data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
             //   [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(bleWorkTimerHandler) userInfo:nil repeats:NO];
            });
        } @catch (NSException *exception) {
           [self processBleWork];
        } @finally {
        }
    });
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)c error:(NSError *)error{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Did write value");
        YokyTag *yt=[self getTagForPeripheral:peripheral];if(yt&&yt.disown)[_cb cancelPeripheralConnection:peripheral];
        //[self onBleWorkComplete:[[peripheral identifier] UUIDString] forChar:[c.UUID UUIDString]];
    });
}

-(NSMutableData *)writeTagConfigHelper:(YokyTag *)yt{
    NSMutableData *d1 = [[NSMutableData alloc]init];
    return d1;
}

-(void)writeTagConfig:(YokyTag *)yt{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CBService *)getServiceFromPeripheral:(CBPeripheral *)peripheral forService:(CBUUID *)uuid{
    NSArray *services=[peripheral services];for(CBService *service in services)if([service.UUID isEqual:uuid])return service;return nil;
}
-(CBCharacteristic *)getCharacteristicFromService:(CBService *)service forCharacteristic:(CBUUID *)uuid{
    for(CBCharacteristic *c in service.characteristics)if([c.UUID isEqual:uuid])return c;return nil;
}

-(YokyTag *)getTagForPeripheral:(CBPeripheral *)peripheral{
    for(int i=0;i<_user.yokyList.count;i++){
        YokyTag *yt=_user.yokyList[i];if([yt.identifier isEqual:[peripheral identifier]]){yt.peripheral=peripheral;return yt;}
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_deviceList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListTableVC" forIndexPath:indexPath];
    CBPeripheral *peri = [_deviceList objectAtIndex:indexPath.row];
    cell.peripheralLabel.text = [NSString stringWithFormat:@"%@",peri.identifier];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPeripheral = _deviceList[indexPath.row];
    if(_isDfuInProgress == YES) {
        NSLog(@"didSelectRow DFU");
        [_cb connectPeripheral:_selectedPeripheral options:nil];
    } else {
        [self analyseTagResponse:_selectedPeripheral andRssi:_rssiList[indexPath.row]];
    }
}

- (IBAction)scanButton:(id)sender {
}

-(void)onConnectionChange:(BOOL)connection withPeripheral: (CBPeripheral*) peripheral {
    if(connection == NO) {
        if(peripheral.identifier == _selectedPeripheral.identifier) {
            _isDfuInProgress = YES;
            [_deviceList removeAllObjects];
            [_tableView reloadData];
            [self startLeScan];
        }
    }
}
-(void)initiateDfu {
    
    NSLog(@"Initiate DFU");
    NSURL *url = [self getBundledFirmwareURLHelper];
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager: _cb target:_selectedPeripheral];
    [initiator withFirmware:selectedFirmware];
    // Optional:
    // initiator.forceDfu = YES/NO; // default NO
    // initiator.packetReceiptNotificationParameter = N; // default is 12
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors
    initiator.progressDelegate = self; // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used
    
    DFUServiceController *controller = [initiator start];
}

-(NSURL*)getBundledFirmwareURLHelper {
    
    return [[NSBundle mainBundle] URLForResource:@"glo_dfu"
                            withExtension:@"zip"];
}

@end
