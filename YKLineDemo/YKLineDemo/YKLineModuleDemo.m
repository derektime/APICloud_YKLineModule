//
//  YKLineModuleDemo.m
//  ModuleDemo
//
//  Created by zhanshi.wang on 2018/8/18.
//  Copyright © 2018年 APICloud. All rights reserved.
//

#import "YKLineModuleDemo.h"
#import "NSDictionaryUtils.h"
#import "Masonry.h"
#import "Y_StockChartView.h"
#import "Y_KLineGroupModel.h"
#import "UIColor+Y_StockChart.h"

@interface YKLineModuleDemo ()<Y_StockChartViewDataSource>
{
    
}

@property (nonatomic, strong) Y_StockChartView *stockChartView;

@property (nonatomic, strong) Y_KLineGroupModel *groupModel;

@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;

@property (nonatomic, strong) NSDictionary *sourceDict;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, assign) NSInteger cbId;

@end

@implementation YKLineModuleDemo

- (void)addKLine:(NSDictionary *)paramDict {
    
    _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    
    CGFloat x = [paramDict floatValueForKey:@"x" defaultValue:0.0];
    CGFloat y = [paramDict floatValueForKey:@"y" defaultValue:0.0];
    CGFloat w = [paramDict floatValueForKey:@"w" defaultValue:0.0];
    CGFloat h = [paramDict floatValueForKey:@"h" defaultValue:0.0];
    [self.stockChartView setFrame:CGRectMake(x, y, w, h)];
    
    [self stockDatasWithIndex:0];
    
    NSString *fixedOn = [paramDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramDict boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:_stockChartView fixedOn:fixedOn fixed:fixed];
    
}

/*
 * self.type: @"minutesList" @"dayList" @"weeksList" @"monthList"
 */
- (void)getDataList:(NSDictionary *)paramDict {
    NSArray *list = [paramDict arrayValueForKey:self.type defaultValue:@[]];
    [self reloadData:list];
}

- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict
{
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
}

-(id) stockDatasWithIndex:(NSInteger)index
{
    [self.stockChartView setUserInteractionEnabled:NO];
    NSString *type;
    switch (index) {
            
        case 0:
        {
            type = @"minutesList";
        }
            break;
        case 1:
        {
            type = @"dayList";
        }
            break;
        case 2:
        {
            type = @"weeksList";
        }
            break;
        case 3:
        {
            type = @"monthList";
        }
            break;
        case 4:
        {
            type = @"minutesList";
        }
            break;
        default:
            break;
    }
    
    self.currentIndex = index;
    self.type = type;
    if(![self.modelsDict objectForKey:type])
    {
        [self sendResultEventWithCallbackId:_cbId dataDict:@{@"type" : type} errDict:nil doDelete:NO];
    } else {
        [self.stockChartView setUserInteractionEnabled:YES];
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}

- (void)reloadData:(NSArray*)dataArray
{
    NSLog(@"dataArray %@",dataArray);
    
    [self.stockChartView setUserInteractionEnabled:YES];
    
    if (dataArray == nil || dataArray.count == 0) {
        return;
    }
    
    NSMutableArray *mDataList = [NSMutableArray new];
    [mDataList addObjectsFromArray:dataArray];
    
    if (mDataList.count < 10){
        for (int i = 0; i < 20; i++){
            [mDataList addObjectsFromArray:dataArray];
        }//小于10条不能成图
    }
    
    Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:mDataList];
    self.groupModel = groupModel;
    [self.modelsDict setObject:groupModel forKey:self.type];
    [self.stockChartView reloadData];
}

- (Y_StockChartView *)stockChartView
{
    if(!_stockChartView) {
        _stockChartView = [Y_StockChartView new];
        _stockChartView.itemModels = @[
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"月线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther]
                                       ];
        _stockChartView.dataSource = self;
    }
    return _stockChartView;
}


@end
