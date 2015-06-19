//
//  MultiMutableArray.h
//  guagua
//
//  Created by liwei wang on 12/6/15.
//  Copyright (c) 2015 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSMutableArray(MultiMutableArray)

-(id)objectAtIndex:(int)i subIndex:(int)s;
-(void)addObject:(id)o toIndex:(int)i;

@end

