//
//  ViewController.m
//  JsonFormatModel
//
//  Created by yuelixing on 2018/8/2.
//  Copyright © 2018年 QingGuo. All rights reserved.
//

#import "ViewController.h"
#import "Logger.h"

@interface ViewController () <NSTextDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;

@property (unsafe_unretained) IBOutlet NSTextView *modelTextView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.jsonTextView.font = [NSFont systemFontOfSize:14];
    self.jsonTextView.delegate = self;
    self.modelTextView.font = [NSFont systemFontOfSize:14];
}
- (IBAction)formatButtonClick:(id)sender {
    if (self.jsonTextView.string.length > 0) {
        NSData * tempData = [self.jsonTextView.string dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error = nil;
        id tempObj = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"%@", error);
            self.modelTextView.string = @"Json 格式不正确";
            self.modelTextView.string = error.localizedDescription;
            self.modelTextView.textColor = [NSColor redColor];
        } else {
            [self formatJsonObject:tempObj];
        }
    }
}

- (void)formatJsonObject:(id)tempObj {
    NSDictionary * jsonDict = nil;
    if ([tempObj isKindOfClass:[NSArray class]]) {
        while (YES) {
            jsonDict = [(NSArray *)tempObj firstObject];
            if ([jsonDict isKindOfClass:[NSArray class]]) {
                jsonDict = [(NSArray *)jsonDict firstObject];
            } else {
                break;
            }
        }
    } else {
        jsonDict = tempObj;
    }
    if (NO == [tempObj isKindOfClass:[NSDictionary class]]) {
        self.modelTextView.string = @"数据中不包含可以解析的字典";
        self.modelTextView.textColor = [NSColor redColor];
        return;
    }
    NSMutableArray<NSMutableArray *> * taregetArray = [[NSMutableArray alloc] init];
    NSMutableArray * firstTaregetArray = [[NSMutableArray alloc] init];
    [taregetArray addObject:firstTaregetArray];
    
    [self formatJsonToPropertyString:jsonDict TargetArray:taregetArray CurrentArray:firstTaregetArray];
    
    NSMutableArray * tempStringArray = [[NSMutableArray alloc] init];
    [taregetArray enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * tempString = [obj componentsJoinedByString:@"\n"];
        [tempStringArray addObject:tempString];
    }];
    self.modelTextView.string = [tempStringArray componentsJoinedByString:@"\n\n"];
    self.modelTextView.textColor = [NSColor blackColor];
}


- (void)formatJsonToPropertyString:(NSDictionary *)jsonDict TargetArray:(NSMutableArray<NSMutableArray *> *)taregetArray CurrentArray:(NSMutableArray *)currentArray {
    NSString * preStrString = @"@property (nonatomic, copy) NSString * ";
    NSString * preNumString = @"@property (nonatomic, assign) NSInteger ";
    NSString * preModelString = @"@property (nonatomic, strong) <#ModelName#> * ";
    NSString * preArrayString = @"@property (nonatomic, strong) NSArray<#ModelName#> * ";
    NSString * preIdString = @"@property (nonatomic, strong) id ";
    [jsonDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNull class]]) {
            NSString * tempString = [NSString stringWithFormat:@"%@%@;// %@", preStrString, key, obj];
            [currentArray addObject:tempString];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            NSString * tempString = [NSString stringWithFormat:@"%@%@;// %@", preNumString, key, obj];
            [currentArray addObject:tempString];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString * tempString = [NSString stringWithFormat:@"%@%@;", preModelString, key];
            [currentArray addObject:tempString];
            
            NSMutableArray * tempTargetArray = [[NSMutableArray alloc] init];
            [taregetArray addObject:tempTargetArray];
            [self formatJsonToPropertyString:obj TargetArray:taregetArray CurrentArray:tempTargetArray];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSString * tempString = [NSString stringWithFormat:@"%@%@;", preArrayString, key];
            [currentArray addObject:tempString];
            
            NSArray * tempObjArray = obj;
            if (tempObjArray.count > 0) {
                while (YES) {
                    obj = [(NSArray *)obj firstObject];
                    if ([obj isKindOfClass:[NSArray class]] == NO) {
                        break;
                    }
                }
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSMutableArray * tempTargetArray = [[NSMutableArray alloc] init];
                    [taregetArray addObject:tempTargetArray];
                    [self formatJsonToPropertyString:obj TargetArray:taregetArray CurrentArray:tempTargetArray];
                }
            }
        } else {
            NSString * tempString = [NSString stringWithFormat:@"%@%@;// %@", preIdString, key, obj];
            [currentArray addObject:tempString];
        }
    }];
}

- (void)textDidChange:(NSNotification *)notification {
    if (self.jsonTextView.string.length == 0) {
        self.modelTextView.string = @"";
    } else {
        NSData * tempData = [self.jsonTextView.string dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error = nil;
        id tempObj = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:&error];
        if (error == nil) {
            [self formatJsonObject:tempObj];
        }
    }
}


@end
