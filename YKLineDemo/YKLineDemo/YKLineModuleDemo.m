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
    
    self.sourceDict = [[NSDictionary alloc]initWithDictionary:paramDict];
    
    [self stockDatasWithIndex:0];
    
    CGFloat x = [paramDict floatValueForKey:@"x" defaultValue:0.0];
    CGFloat y = [paramDict floatValueForKey:@"y" defaultValue:0.0];
    CGFloat w = [paramDict floatValueForKey:@"w" defaultValue:0.0];
    CGFloat h = [paramDict floatValueForKey:@"h" defaultValue:0.0];
    [_stockChartView setFrame:CGRectMake(x, y, w, h)];
    
    NSString *fixedOn = [paramDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramDict boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:_stockChartView fixedOn:fixedOn fixed:fixed];
    
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
        [self reloadData];
    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}

- (void)reloadData
{
    if (self.sourceDict == nil) {
        return;
    }
    
    NSArray *dataList = [self.sourceDict arrayValueForKey:self.type defaultValue:@[]];
    
    NSMutableArray *mDataList = [NSMutableArray new];
    [mDataList addObjectsFromArray:dataList];
    
    NSLog(@"dataList %@",dataList);
    
    if (dataList.count < 10){
        for (int i = 0; i < 20; i++){
            [mDataList addObjectsFromArray:dataList];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"#1#\n%@",dataList] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];  //小于10条不能成图
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
