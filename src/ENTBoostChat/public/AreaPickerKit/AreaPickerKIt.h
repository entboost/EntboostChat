//
//  AreaPickerView.h
//  areapicker
//
//  Created by zhongzf on 15-10-9.
//
//

#import <UIKit/UIKit.h>

@class EBArea;
@class AreaPickerKit;

@protocol AreaPickerDelegate <NSObject>

@required
/**
 * @param picker
 * @param parentAreaId 上级地区编号
 * @return 下级地区队列
 */
- (NSArray*)areaPickerData:(AreaPickerKit *)pickerKit parentAreaId:(uint64_t)parentAreaId;

@optional
/**
 * @param picker
 * @param selectedArea 选中的地区数据
 */
- (void)pickerDidChangeStatus:(AreaPickerKit *)pickerKit selectedArea:(EBArea*)selectedArea;

@end


@interface AreaPickerKit : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property(weak, nonatomic) id<AreaPickerDelegate> delegate;
@property(strong, nonatomic) UIPickerView *pickerView;
@property(strong, nonatomic) EBArea *selectedArea; //选中的地区数据

- (id)initWithArea:(EBArea*)area delegate:(id<AreaPickerDelegate>)delegate;

- (void)cancelPicker;

@end
