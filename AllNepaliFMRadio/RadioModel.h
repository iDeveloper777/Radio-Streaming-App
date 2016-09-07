//
//  BrandModel.h
//  Muse
//
//  Created by Pasca Maulana on 12/10/14.
//  Copyright (c) 2014 Digi. All rights reserved.
//

#ifndef Muse_BrandModel_h
#define Muse_BrandModel_h

#import <Foundation/Foundation.h>

@protocol RadioModel
@end


@interface RadioModel : NSObject

@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* station_name;
@property (strong, nonatomic) NSString* website_address;

-(instancetype) initWithJSONData:(NSDictionary *) jsondata;

@end

#endif
