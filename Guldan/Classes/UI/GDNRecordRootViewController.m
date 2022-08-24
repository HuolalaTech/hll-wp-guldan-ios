//
//  GDNRecordRootViewController.m
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import "GDNRecordRootViewController.h"
#import "GDNOCMethodTimeProfiler.h"
#import "GDNUIModel.h"
#import "GDNRecordDetailViewController.h"

@interface GDNRecordRootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, copy) NSArray *modelData;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GDNRecordRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.titleLabel];
    // Do any additional setup after loading the view.
    [self reloadTableview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableview) name:GDNRecordsDataDidReadyNotification object:nil];
}

- (void)reloadTableview {
    _modelData = [GDNOCMethodTimeProfiler modelsArr];
    [self.tableview reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"TPMainTableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 36, [UIScreen mainScreen].bounds.size.width, 1)];
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"耗时详情 - %ld", indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Thread: main-thread";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _modelData.count) {
        GDNUIModel *model = _modelData[indexPath.row];
        GDNRecordDetailViewController *vc = [[GDNRecordDetailViewController alloc] initWithModel:model];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - private

- (void)clickCloseBtn:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)getTPBtnWithFrame:(CGRect)rect title:(NSString *)title sel:(SEL)sel {
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.layer.cornerRadius = 2;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:127/255.0 green:179/255.0 blue:219/255.0 alpha:1]] forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - get&set method

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
        _tableview.bounces = NO;
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.rowHeight = 38;
        _tableview.sectionHeaderHeight = 50;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableview;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [self getTPBtnWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 65, 40, 30) title:@"关闭" sel:@selector(clickCloseBtn:)];
    }
    return _closeBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 55, [UIScreen mainScreen].bounds.size.width - 120, 50)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:25];
        _titleLabel.text = @"TimeProfiler";
    }
    return _titleLabel;
}

@end
