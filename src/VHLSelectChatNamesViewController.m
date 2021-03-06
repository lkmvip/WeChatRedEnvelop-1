//
//  VHLSelectChatNamesViewController.m
//  opendevtest
//
//  Created by vincent on 2017/3/1.
//
//

#import "VHLSelectChatNamesViewController.h"
//
#import "WeChatRedEnvelop.h"
#import <objc/objc-runtime.h>

@interface VHLSelectChatNamesViewController ()<ContactSelectViewDelegate>

@property (nonatomic, strong) ContactSelectView *selectView;
@property (nonatomic, strong) NSArray *chatNames;

@end

@implementation VHLSelectChatNamesViewController

- (instancetype)initWithChatNames:(NSArray *)chatNames {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _chatNames = chatNames;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitleArea];
    [self initSelectView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MMServiceCenter *serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    CContactMgr *contactMgr = [serviceCenter getService:objc_getClass("CContactMgr")];
    
    for (NSString *contactName in self.chatNames) {
        CContact *contact = [contactMgr getContactByName:contactName];
        [self.selectView addSelect:contact];
    }
}

- (void)initTitleArea {
    self.navigationItem.leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"取消" target:self action:@selector(onCancel:) style:0];
    
    self.navigationItem.rightBarButtonItem = [self rightBarButtonWithSelectCount:self.chatNames.count];
    
    self.title = @"选择群聊";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (UIBarButtonItem *)rightBarButtonWithSelectCount:(unsigned long)selectCount {
    
    UIBarButtonItem *barButtonItem;
    if (selectCount == 0) {
        barButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"确定" target:self action:@selector(onDone:) style:2];
    } else {
        NSString *title = [NSString stringWithFormat:@"确定(%lu)", selectCount];
        barButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:title target:self action:@selector(onDone:) style:4];
    }
    return barButtonItem;
}

- (void)onCancel:(UIBarButtonItem *)item {
    if ([self.delegate respondsToSelector:@selector(onSelectChatNamesCancel)]) {
        [self.delegate onSelectChatNamesCancel];
    }
}

- (void)onDone:(UIBarButtonItem *)item {
    if ([self.delegate respondsToSelector:@selector(onSelectChatNamesReturn:)]) {
        NSArray *blacklist = [[self.selectView.m_dicMultiSelect allKeys] copy];
        [self.delegate onSelectChatNamesReturn:blacklist];
    }
}

- (void)initSelectView {
    self.selectView = [[objc_getClass("ContactSelectView") alloc] initWithFrame:[UIScreen mainScreen].bounds delegate:self];
    
    self.selectView.m_uiGroupScene = 5;
    self.selectView.m_bMultiSelect = YES;
    [self.selectView initData:5];
    [self.selectView initView];
    
    [self.view addSubview:self.selectView];
}

#pragma mark - ContactSelectViewDelegate
- (void)onSelectContact:(CContact *)arg1 {
    self.navigationItem.rightBarButtonItem = [self rightBarButtonWithSelectCount:[self getTotalSelectCount]];
}

- (unsigned long)getTotalSelectCount {
    return (unsigned long)[self.selectView.m_dicMultiSelect count];
}

@end
