//
//  JCMomentLocation.m
//  PYQDemo
//
//  Created by Guo.JC on 2017/9/2.
//  Copyright © 2017年 coollang. All rights reserved.
//

#import "JCMomentLocation.h"

static JCMomentLocation *_manager;

@interface JCMomentLocation  ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *locationStr;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLGeocoder *geoCode;
@property (nonatomic, copy) CompletionHandler complete;
@property (nonatomic, copy) GetLocationComplete getLocationBlock;


@end

@implementation JCMomentLocation

+ (instancetype)shareInstance {
    static JCMomentLocation *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JCMomentLocation alloc] init];
    });
    return _manager;
}

- (void)getCLLocationCallBack:(GetLocationComplete)locationBlock {
    self.getLocationBlock = locationBlock;
    [self startLocation];
}
// 开始定位
- (void)startLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"-------->开始定位");
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        //控制定位精度,越高耗电量越大
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        // 总是授权
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.distanceFilter = 10.0f;
        [self.locationManager startUpdatingLocation];
    }else {
        NSLog(@"-------->定位服务无法使用");
        if (self.getLocationBlock) {
            self.getLocationBlock(nil, [NSError errorWithDomain:@"定位服务无法使用" code:-1 userInfo:nil]);
            self.getLocationBlock = nil;
        }
    }
}

#pragma mark - 回调代理
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
    [self stopLocation];
    if (self.getLocationBlock) {
        self.getLocationBlock(nil, error);
        self.getLocationBlock = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = locations[0];
    
    if (self.getLocationBlock) {
        self.getLocationBlock(newLocation, nil);
        self.getLocationBlock = nil;
    }
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
                self.locationStr = city;
            }
            NSLog(@"city = %@  %@", city, placemark.administrativeArea);
            self.locationStr = [NSString stringWithFormat:@"%@%@",placemark.administrativeArea,city];
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

- (void)stopLocation {
    [self.locationManager stopUpdatingLocation];
}

/**
 经纬度反编译成地址
 */
- (void)reverseGeocodeLocationWithLatitude:(double) latitude
                                 longitude:(double) longitude
                                  complete:(CompletionHandler) completionHandler{
    self.complete = completionHandler;
    // 反地理编码
    self.geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSString *address;
        // 错误处理
        if (error || placemarks == nil || [placemarks count] == 0) {
            NSLog(@"反地理编码错误");
            address = @"";
        }else{
            // CLPlacemark 地标对象 包含CLLocation 位置对象 还有 街道 国家 行政区域描述信息
            // name 详细地址 thoroughfare 街道 country 国家 administrativeArea 省份 直辖市
            for (CLPlacemark *placeMark in placemarks) {
                NSDictionary *addressDic = placeMark.addressDictionary;
                NSString *state=[addressDic objectForKey:@"State"];
                NSString *city=[addressDic objectForKey:@"City"];
//                NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
//                NSString *street=[addressDic objectForKey:@"Street"];
                address = [NSString stringWithFormat:@"%@·%@", state, city];
            }
        }
//        NSLog(@"经纬度反编译的所在城市====%@", address);
        if (self.complete) {
            self.complete(address);
            self.complete = nil;
        }
    }];
}

// 地址编译成经纬度
- (void)geocodeAddressString:(NSString *)address geocodeCallBack:(GetLocationComplete)geocodeBlock {
    self.geoCode = [[CLGeocoder alloc] init];
    // 地理编码
    [self.geoCode geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        // 错误处理
        if (error || placemarks == nil || [placemarks count] == 0) {
            NSLog(@"地理编码错误");
            if (geocodeBlock) {
                geocodeBlock(nil,error);
            }
            return;
        }
        
        if (geocodeBlock) {
            geocodeBlock(placemarks.firstObject.location,nil);
        }
        
        // CLPlacemark 地标对象 包含CLLocation 位置对象 还有 街道 国家 行政区域描述信息
        // name 详细地址 thoroughfare 街道 country 国家 administrativeArea 省份 直辖市
        for (CLPlacemark *pm in placemarks) {
            // 经纬度
            NSLog(@"经纬度:%f %f",pm.location.coordinate.longitude,pm.location.coordinate.latitude);
            // 其它描述信息
            NSLog(@"CLPlacemark:%@ %@ %@ %@",pm.name,pm.thoroughfare,pm.country,pm.administrativeArea);
        }
    }];
}


@end
