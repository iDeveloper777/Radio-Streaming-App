//
//  BrandModel.m
//  Muse
//
//  Created by Pasca Maulana on 12/10/14.
//  Copyright (c) 2014 Digi. All rights reserved.
//

#import "RadioModel.h"

@implementation RadioModel

- (instancetype) initWithJSONData:(NSDictionary *)jsondata
{
    _address = [jsondata objectForKey:@"address"];
    _id = [jsondata objectForKey:@"id"];
    _station_name = [jsondata objectForKey:@"station_name"];
    _url = [jsondata objectForKey:@"url"];
    _website_address = [jsondata objectForKey:@"website_address"];
    return self;
}
@end
