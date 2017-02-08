//
//  ViewController.h
//  DFU Test
//
//  Created by Aahir Giri on 06/02/17.
//  Copyright © 2017 Aahir Giri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleWorker.h"
#import "iOSDFULibrary-Swift.h"


@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>


@end

