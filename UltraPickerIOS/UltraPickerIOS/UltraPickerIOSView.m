//
//  UPIView.m
//  Ultra-Picker-iOS
//
//  Created by Tim Sawtell on 3/9/17.
//  Copyright © 2017 Sportsbet. All rights reserved.
//

#import "UltraPickerIOSView.h"

@interface UltraPickerIOSView() <UIPickerViewDataSource, UIPickerViewDelegate>

@end

CGFloat const UIPickerDefaultFontSize = 17.0;
NSString const *UIPickerDefaultFontFamily = @"HelveticaNeue";

@implementation UltraPickerIOSView

NSArray *_appendixViews;
CGFloat _widthForComponents;

- (void) setComponentsData:(NSArray *)componentsData
{
    if (componentsData != _componentsData) {
        _componentsData = [componentsData copy];
        _widthForComponents = 0;
        NSMutableArray *tempArray = [NSMutableArray new];
        if ([_appendixViews isKindOfClass:[NSArray class]]) {
            [_appendixViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        for (NSDictionary *item in componentsData) {
            NSString *groupFontFamily = [item valueForKey:@"fontFamily"];
            NSString *groupFontSize = [item valueForKey:@"fontSize"];
            CGFloat groupWidth = [[item valueForKey:@"width"] floatValue];
            NSString *fontName = groupFontFamily ?: UIPickerDefaultFontFamily;
            float fontSize = groupFontSize.floatValue > 0 ? groupFontSize.floatValue : UIPickerDefaultFontSize;
            UILabel *label = [UILabel new];
            label.font = [UIFont fontWithName:fontName size:fontSize];
            label.text = [item valueForKey:@"appendix"];
            label.textAlignment = NSTextAlignmentRight;
            label.frame = CGRectMake(0, 0, groupWidth, fontSize);
            [tempArray addObject:label];
            [self addSubview:label];
            _widthForComponents += groupWidth;
        }
        NSLog(@"WIDTH FOR COMPONENTS: %f", _widthForComponents);
        _appendixViews = [NSArray arrayWithArray:tempArray];
        
        [self setNeedsLayout];
        
        if (self.selectedIndexes) {
            for (NSInteger i = 0; i < self.selectedIndexes.count; i++) {
                if (i < self.componentsData.count) {
                    NSInteger index = [self.selectedIndexes[i] integerValue];
                    [self selectRow:index inComponent:i animated:NO];
                }
            }
        }
    }
}

- (void) setSelectedIndexes:(NSArray<NSNumber *> *)selectedIndexes
{
    _selectedIndexes = selectedIndexes;
    if (!self.componentsData) {
        return;
    }
    for (NSInteger i = 0; i < selectedIndexes.count; i++) {
        NSInteger index = [selectedIndexes[i] integerValue];
        [self selectRow:index inComponent:i animated:NO];
    }
}

- (void) setTestID:(NSString *)testID
{
    _testID = testID;
    self.accessibilityIdentifier = testID;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Never return zero, or the selection indicator lines won't render
    return MAX(self.componentsData.count, 1);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Never return zero, or the selection indicator lines won't render
    return MAX([[[self.componentsData objectAtIndex:component] valueForKey:@"items"] count], 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self labelForRow:row forComponent:component];
}

- (NSString *)labelForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"label"];
    if (!text) {
        return @"";
    } else {
        return text;
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UIView *textContainer;
    UILabel *displayLabel;
    
    if (view) {
        textContainer = view;
        displayLabel = (UILabel *)[[view subviews] objectAtIndex:0];
    } else {
        displayLabel = [UILabel new];
        textContainer = [UIView new];
        displayLabel.textAlignment = NSTextAlignmentCenter;
        [textContainer addSubview:displayLabel];
    }
    
    NSString *groupFontFamily = [[self.componentsData objectAtIndex:component] valueForKey:@"fontFamily"];
    NSString *groupFontSize = [[self.componentsData objectAtIndex:component] valueForKey:@"fontSize"];
    
    CGRect labelRect = [[[self.componentsData objectAtIndex:component] valueForKey:@"appendix"]
                        boundingRectWithSize:CGSizeMake(200, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:groupFontFamily size:groupFontSize.doubleValue]
                                     }
                        context:nil];
    
    CGFloat width = [self pickerView:self widthForComponent:component];
    CGFloat height = [self pickerView:self widthForComponent:component];
    textContainer.bounds = CGRectMake(0, 0, width, height);
    displayLabel.frame = CGRectMake(0, 0, width - labelRect.size.width, height);
    displayLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *fontName;
    CGFloat fontSize;
    UIFont *font = nil;
    
    //Check for property on the Item first, then the Group
    NSString *itemFontFamily = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"fontFamily"];
    NSString *itemFontSize = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"fontSize"];
    
    if (itemFontFamily != nil || itemFontSize != nil) {
        fontName = itemFontFamily ?: UIPickerDefaultFontFamily;
        fontSize = itemFontSize.integerValue > 0 ? itemFontSize.doubleValue : UIPickerDefaultFontSize;
    }else {
        fontName = groupFontFamily ?: UIPickerDefaultFontFamily;
        fontSize = groupFontSize.integerValue > 0 ? groupFontSize.doubleValue : UIPickerDefaultFontSize;
    }
    
    font = [UIFont fontWithName:fontName size:fontSize];
    
    if (font) {
        displayLabel.font = font;
    }
    
    displayLabel.text = [self labelForRow:row forComponent:component];
    
    return textContainer;
}

- (NSString *)valueForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"value"];
    if (!text) {
        return @"";
    } else {
        return text;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *event = @{
                            @"newIndex": @(row),
                            @"component": @(component),
                            @"newValue": [self valueForRow:row forComponent:component],
                            @"newLabel": [self labelForRow:row forComponent:component]
                            };
    
    if (self.onChange) {
        self.onChange(event);
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width = [[[self.componentsData objectAtIndex:component] valueForKey:@"width"] doubleValue];
    if (!width) {
        return 40;
    } else {
        return width;
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    NSUInteger count = 0;
    CGFloat xOffset = (self.frame.size.width - _widthForComponents) / 2;
    for (UILabel *label in _appendixViews) {
        CGRect frame = label.frame;
        frame.origin.x = xOffset;
        frame.origin.y = (self.frame.size.height / 2) - (label.font.pointSize / 2);
        label.frame = frame;
        xOffset += frame.size.width;
        count++;
    }
}
@end
