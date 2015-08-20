//
//  MyTextView.m
//  SugarNursing
//
//  Created by Dan on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MyTextView.h"

@interface MyTextView ()

@property (strong, nonatomic) UILabel *placeholderLabel;

@end

@implementation MyTextView

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)aNotification
{
    if ([[self placeholder] length] == 0) {
        return;
    }
    [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
        if ([[self text] length] == 0) {
            [[self viewWithTag:999] setAlpha:1];
        } else {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textChanged:nil];
}

- (void)paste:(id)sender
{
    [super paste:sender];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeholderLabel == nil )
        {
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeholderLabel.numberOfLines = 0;
            _placeholderLabel.font = self.font;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            _placeholderLabel.textColor = self.placeholderColor;
            _placeholderLabel.alpha = 0;
            _placeholderLabel.tag = 999;
            [self addSubview:_placeholderLabel];
        }
        
        _placeholderLabel.text = self.placeholder;
        [_placeholderLabel sizeToFit];
        [self sendSubviewToBack:_placeholderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

@end
