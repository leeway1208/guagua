//
//  MultiMutableArray.m
//  guagua
//
//  Created by liwei wang on 12/6/15.
//  Copyright (c) 2015 leeway. All rights reserved.
//

#import "MultiMutableArray.h"

@implementation NSMutableArray(MultiMutableArray)

-(id)objectAtIndex:(int)i subIndex:(int)s
{
    id subArray = [self objectAtIndex:i];
    return [subArray isKindOfClass:NSArray.class] ? [subArray objectAtIndex:s] : nil;
}

-(void)addObject:(id)o toIndex:(int)i
{
    while(self.count <= i)
        [self addObject:NSMutableArray.new];
    NSMutableArray* subArray = [self objectAtIndex:i];
    [subArray addObject: o];
}

@end