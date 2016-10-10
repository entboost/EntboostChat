//
//  AreaPickerView.m
//  areapicker
//  Created by zhongzf on 15-10-9.
//
//

#import "AreaPickerKit.h"
#import "EBArea.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface AreaPickerKit ()

@property(strong, nonatomic) NSArray* field0s;
@property(strong, nonatomic) NSArray* field1s;
@property(strong, nonatomic) NSArray* field2s;
@property(strong, nonatomic) NSArray* field3s;

@end

@implementation AreaPickerKit

- (id)initWithArea:(EBArea*)area delegate:(id<AreaPickerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.selectedArea = area;
        
        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.userInteractionEnabled  = YES;
        self.pickerView.showsSelectionIndicator = YES;
        
        [self prepareForSelectedArea];
    }
    return self;
    
}

//准备预选中资料
- (void)prepareForSelectedArea
{
    self.field0s = [self.delegate areaPickerData:self parentAreaId:0];
    
    if (self.selectedArea) {
        BOOL loaded = NO;
        
        EBArea* area = self.selectedArea;
        if (area.field0>0) {
            [self.field0s enumerateObjectsUsingBlock:^(EBAreaField* field, NSUInteger idx, BOOL *stop) {
                if (area.field0==field.aId) {
                    [self.pickerView selectRow:idx inComponent:0 animated:YES];
                    *stop = YES;
                }
            }];
            
            //加载下一列数据
            self.field1s = [self.delegate areaPickerData:self parentAreaId:area.field0];
            if (area.field1==0)
                loaded = YES;
        } else {
            if (self.field0s.count>=2) {
                loaded = YES;
                EBAreaField* field = self.field0s[1];
                self.field1s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            }
        }
        
        [self.pickerView reloadComponent:1];
        
        if (area.field1>0) {
            [self.field1s enumerateObjectsUsingBlock:^(EBAreaField* field, NSUInteger idx, BOOL *stop) {
                if (area.field1==field.aId) {
                    [self.pickerView selectRow:idx inComponent:1 animated:YES];
                    *stop = YES;
                }
            }];
            
            //加载下一列数据
            self.field2s = [self.delegate areaPickerData:self parentAreaId:area.field1];
            if (area.field2==0)
                loaded = YES;
        } else {
            if (self.field1s.count>=2 && !loaded) {
                loaded = YES;
                EBAreaField* field = self.field1s[1];
                self.field2s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            }
        }
        
        [self.pickerView reloadComponent:2];
        
        if (area.field2>0) {
            [self.field2s enumerateObjectsUsingBlock:^(EBAreaField* field, NSUInteger idx, BOOL *stop) {
                if (area.field2==field.aId) {
                    [self.pickerView selectRow:idx inComponent:2 animated:YES];
                    *stop = YES;
                }
            }];
            
            //加载下一列数据
            self.field3s = [self.delegate areaPickerData:self parentAreaId:area.field2];
            if (area.field3==0)
                loaded = YES;
        } else {
            if (self.field2s.count>=2 && !loaded) {
                loaded = YES;
                EBAreaField* field = self.field2s[1];
                self.field3s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            }
        }
        
        [self.pickerView reloadComponent:3];
        
        if (area.field3>0) {
            [self.field3s enumerateObjectsUsingBlock:^(EBAreaField* field, NSUInteger idx, BOOL *stop) {
                if (area.field3==field.aId) {
                    [self.pickerView selectRow:idx inComponent:3 animated:YES];
                    *stop = YES;
                }
            }];
        }
    } else if (self.field0s.count>0){
        //保存默认选中
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        EBAreaField* field = [self.field0s objectAtIndex:0];
        [self saveChangeWithField:field inComponent:0];
    }
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch(component) {
        case 0:
            return [self.field0s count];
            break;
        case 1:
            return [self.field1s count];
            break;
        case 2:
            return [self.field2s count];
            break;
        case 3:
            return [self.field3s count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [((EBAreaField*)[self.field0s objectAtIndex:row]) name];
            break;
        case 1:
            return [((EBAreaField*)[self.field1s objectAtIndex:row]) name];
            break;
        case 2:
            return [((EBAreaField*)[self.field2s objectAtIndex:row]) name];
            break;
        case 3:
            return [((EBAreaField*)[self.field3s objectAtIndex:row]) name];
            break;
        default:
            return  @"";
            break;
    }
}

- (void)saveChangeWithField:(EBAreaField*)areaField inComponent:(NSInteger)component
{
    if (component<0)
        return;
        
    if (!self.selectedArea)
        self.selectedArea = [[EBArea alloc] init];
    
    switch (component) {
        case 0:
        {
            if (areaField) {
                self.selectedArea.field0 = areaField.aId;
                self.selectedArea.strField0 = areaField.name;
            } else {
                self.selectedArea.field0 = 0;
                self.selectedArea.strField0 = nil;
            }
        }
            break;
        case 1:
        {
            if (areaField) {
                self.selectedArea.field1 = areaField.aId;
                self.selectedArea.strField1 = areaField.name;
            } else {
                self.selectedArea.field1 = 0;
                self.selectedArea.strField1 = nil;
            }
        }
            break;
        case 2:
        {
            if (areaField) {
                self.selectedArea.field2 = areaField.aId;
                self.selectedArea.strField2 = areaField.name;
            } else {
                self.selectedArea.field2 = 0;
                self.selectedArea.strField2 = nil;
            }
        }
            break;
        case 3:
        {
            if (areaField) {
                self.selectedArea.field3 = areaField.aId;
                self.selectedArea.strField3 = areaField.name;
            } else {
                self.selectedArea.field3 = 0;
                self.selectedArea.strField3 = nil;
            }
        }
            break;
        default:
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            if (self.field0s.count==0)
                return;
            
            //保存当前选中状态
            EBAreaField* field = [self.field0s objectAtIndex:row];
            [self saveChangeWithField:field inComponent:component];
            
            NSInteger selectedRow;
            selectedRow = [pickerView selectedRowInComponent:1];
            [self saveChangeWithField:/*self.field1s.count>0?[self.field1s objectAtIndex:selectedRow]:*/nil inComponent:1];
            
            selectedRow = [pickerView selectedRowInComponent:2];
            [self saveChangeWithField:/*self.field2s.count>0?[self.field2s objectAtIndex:selectedRow]:*/nil inComponent:2];
            
            selectedRow = [pickerView selectedRowInComponent:3];
            [self saveChangeWithField:/*self.field3s.count>0?[self.field3s objectAtIndex:selectedRow]:*/nil inComponent:3];
            
            //加载新状态
            if (field.aId)
                self.field1s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            else
                self.field1s = nil;
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            
            self.field2s = nil;
            [pickerView reloadComponent:2];
            
            self.field3s = nil;
            [pickerView reloadComponent:3];
        }
            break;
        case 1:
        {
            if (self.field1s.count==0)
                return;
            
            //保存当前选中状态
            EBAreaField* field = [self.field1s objectAtIndex:row];
            [self saveChangeWithField:field inComponent:component];
            
            NSInteger selectedRow;
//            selectedRow = [pickerView selectedRowInComponent:0];
//            [self saveChangeWithField:/*self.field0s.count>0?[self.field0s objectAtIndex:selectedRow]:*/nil inComponent:0];
            
            selectedRow = [pickerView selectedRowInComponent:2];
            [self saveChangeWithField:/*self.field2s.count>0?[self.field2s objectAtIndex:selectedRow]:*/nil inComponent:2];
            
            selectedRow = [pickerView selectedRowInComponent:3];
            [self saveChangeWithField:/*self.field3s.count>0?[self.field3s objectAtIndex:selectedRow]:*/nil inComponent:3];
            
            //加载新状态
            if (field.aId)
                self.field2s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            else
                self.field2s = nil;
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            self.field3s = nil;
            [pickerView reloadComponent:3];
        }
            break;
        case 2:
        {
            if (self.field2s.count==0)
                return;
            
            //保存当前选中状态
            EBAreaField* field = [self.field2s objectAtIndex:row];
            [self saveChangeWithField:field inComponent:component];
            
            NSInteger selectedRow;
//            selectedRow = [pickerView selectedRowInComponent:1];
//            [self saveChangeWithField:/*self.field1s.count>0?[self.field1s objectAtIndex:selectedRow]:*/nil inComponent:1];
//            
//            selectedRow = [pickerView selectedRowInComponent:0];
//            [self saveChangeWithField:/*self.field0s.count>0?[self.field0s objectAtIndex:selectedRow]:*/nil inComponent:0];
            
            selectedRow = [pickerView selectedRowInComponent:3];
            [self saveChangeWithField:/*self.field3s.count>0?[self.field3s objectAtIndex:selectedRow]:*/nil inComponent:3];
            
            //加载新状态
            if (field.aId)
                self.field3s = [self.delegate areaPickerData:self parentAreaId:field.aId];
            else
                self.field3s = nil;
            [pickerView reloadComponent:3];
            [pickerView selectRow:0 inComponent:3 animated:YES];
        }
            break;
        case 3:
        {
            if (self.field3s.count==0)
                return;
            
            //保存当前选中状态
            EBAreaField* field = [self.field3s objectAtIndex:row];
            [self saveChangeWithField:field inComponent:component];
            
//            NSInteger selectedRow;
//            selectedRow = [pickerView selectedRowInComponent:1];
//            [self saveChangeWithField:/*self.field1s.count>0?[self.field1s objectAtIndex:selectedRow]:*/nil inComponent:1];
//            
//            selectedRow = [pickerView selectedRowInComponent:2];
//            [self saveChangeWithField:/*self.field2s.count>0?[self.field2s objectAtIndex:selectedRow]:*/nil inComponent:2];
//            
//            selectedRow = [pickerView selectedRowInComponent:0];
//            [self saveChangeWithField:/*self.field0s.count>0?[self.field0s objectAtIndex:selectedRow]:*/nil inComponent:0];
        }
            break;
        default:
            break;
    }
    
    //通知选中数据变更
    if([self.delegate respondsToSelector:@selector(pickerDidChangeStatus:selectedArea:)]) {
        [self.delegate pickerDidChangeStatus:self selectedArea:self.selectedArea];
    }
}

//每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width = pickerView.bounds.size.width;
    
//    return floor((width-40)/4);
//    if (width>320)
    return width*((float)85/414);
//    else
//        return 50;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.minimumScaleFactor = 10.0/[UIFont labelFontSize];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:12];
        pickerLabel.backgroundColor = [UIColor clearColor];
    }
    
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

#pragma mark - animation

//- (void)showInView:(UIView *)view
//{
////    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
////    [view addSubview:self];
////    
////    [UIView animateWithDuration:0.3 animations:^{
////        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
////    }];
//    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//}

- (void)cancelPicker
{
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
//                     }
//                     completion:^(BOOL finished){
//                         [self removeFromSuperview];
//                         
//                     }];
    [self removeFromSuperview];
}

@end
