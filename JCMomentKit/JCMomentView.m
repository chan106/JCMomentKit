//
//  JCMomentView.m
//  JCMomentKit
//
//  Created by 郭吉成 on 2018/1/15.
//  Copyright © 2018年 KOOSPUR. All rights reserved.
//

#import "JCMomentView.h"
#import "JCMomentKit.h"
#import "YYKit.h"
#import "JCMomentCommentInputView.h"
#import "MJRefresh.h"

@interface JCMomentView ()<UITableViewDataSource, UITableViewDelegate,JCMomentCellDelegate>

@property (nonatomic, strong) NSMutableArray <JCMomentsModel *> *momentModels;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JCMomentCommentInputView *inputView;

@end

@implementation JCMomentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initCode];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initCode];
    }
    return self;
}

- (void)initCode{
    self.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    NSBundle *xibBundle = [NSBundle bundleForClass:[self class]];
    [_tableView registerNib:[UINib nibWithNibName:@"JCMomentCell" bundle:xibBundle] forCellReuseIdentifier:@"JCMomentCell"];
    _tableView.tableFooterView = [UIView new];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [self addNotice];
    [self addRefresh];
}

- (void)setSeparatorColor:(UIColor *)separatorColor{
    _separatorColor = separatorColor;
    _tableView.separatorColor = separatorColor;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _tableView.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    _tableView.frame = self.bounds;
    _tableView.backgroundColor = [UIColor clearColor];
    if (_inputView == nil) {
        _inputView = [[JCMomentCommentInputView alloc] initWithFrame:CGRectMake(0, kJCMomentScreenHeight, self.frame.size.width, kInputViewMinHeight)];
        [_inputView sendButtonBackColor:_sendButtonBackColor tinColor:_sendButtonTinColor borderColor:_sendButtonBorderColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    }
}

/**
 注册通知
 */
- (void)addNotice{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(watchUserInfo:)
                                                 name:kNoticeWatchUserInfo
                                               object:nil];
}

- (void)addRefresh{
    __weak typeof(self)weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf dropRefreshData];
    }];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)(_tableView.mj_header)).lastUpdatedTimeLabel.hidden = YES;
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
}

/**
 下拉刷新数据
 */
- (void)dropRefreshData{
    if (self.requestDataBlock) {
        self.requestDataBlock(MomentDataSourceTypeRefresh);
    }
}

/**
 上拉加载更多数据
 */
- (void)loadMore{
    if (self.requestDataBlock) {
        self.requestDataBlock(MomentDataSourceTypeAddMore);
    }
}

/**
 赋予数据
 */
- (void)setMomentDataArray:(NSArray <JCMomentsModel *> *) momentArray
            dataSourceType:(MomentDataSourceType) dataSourceType{
    if (momentArray.count <= 0) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
    }else{
        if (dataSourceType == MomentDataSourceTypeRefresh) {
            _momentModels = momentArray.mutableCopy;
            [_tableView.mj_header endRefreshing];
            [_tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView scrollToRow:0 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else if (dataSourceType == MomentDataSourceTypeAddMore){
            [_momentModels addObjectsFromArray:momentArray];
            [_tableView.mj_footer endRefreshing];
            [_tableView reloadData];
            
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeCancelAllEdit object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    //    int height = keyboardRect.size.height - 49;//这里弹出有BUG，需要更改
    int height = keyboardRect.size.height;
    CGFloat time = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [_inputView updateFrame:CGRectMake(0, kJCMomentScreenHeight - height - kInputViewMinHeight, self.frame.size.width, kInputViewMinHeight) withTime:time];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    CGFloat time = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [_inputView updateFrame:CGRectMake(0, kJCMomentScreenHeight, self.frame.size.width, kInputViewMinHeight)
                   withTime:time];
}

- (void)deleteMoment:(JCMomentsModel *)deleteMoment{
    if ([_momentModels containsObject:deleteMoment]) {
        [_momentModels removeObject:deleteMoment];
        ///删除cell
        [_tableView deleteRow:deleteMoment.indexPath.row
                    inSection:deleteMoment.indexPath.section
             withRowAnimation:UITableViewRowAnimationRight];
        [UIView performWithoutAnimation:^{
            [_tableView reloadData];
        }];
    }else{
        NSAssert(YES, @"帖子数据源中无此模型");
    }
}

- (void)likeMoment:(JCMomentsModel *)likeMoment{
    if ([_momentModels containsObject:likeMoment]) {
        [UIView performWithoutAnimation:^{
            [_tableView reloadRowAtIndexPath:likeMoment.indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    } else {
        NSAssert(YES, @"帖子数据源中无此模型");
    }
}

- (void)deleteCommentResponse:(JCMomentsModel *)momentModel responseModel:(JCMomentResponseModel *)responseModel indexPath:(NSIndexPath *)indexPath{
    [momentModel.responseList removeObjectAtIndex:indexPath.row];
    ///计算评论所需高度
    [momentModel calculCommetHeight];
    ///计算cell高度
    [momentModel caucalCellHeight];
    [_tableView reloadData];
}

/**
 新加一条评论
 @params            responseID      服务器返回的评论ID
 */
- (void)addNewCommentForMoment:(JCMomentsModel *) moment
                    responseID:(NSString *) responseID
                commentContent:(NSString *) commentContent{
    JCMomentResponseModel *newComment = [JCMomentResponseModel creatNewCommentWithText:commentContent
                                                                                postID:moment.topicID
                                                                            responseID:responseID
                                                                         currentUserID:moment.currentUserID
                                                                       currentUserName:moment.currentUserName
                                                                             nameColor:moment.nameColor
                                                                          contentColor:moment.contentColor];
    [moment addCommentModel:newComment];
    [_tableView reloadData];
}

/**
 新加一条回复
 @params            responseID      服务器返回的回复ID
 */
- (void)addNewCommentResponseForMoment:(JCMomentsModel *) moment
                         responseModel:(JCMomentResponseModel *) responseModel
                            responseID:(NSString *) responseID
                       responseContent:(NSString *) responseContent{
    
    JCMomentResponseModel *newResponse = [JCMomentResponseModel creatNewResponseWithText:responseContent
                                                                              responseID:responseID
                                                                            commentModel:responseModel
                                                                           currentUserID:moment.currentUserID
                                                                         currentUserName:moment.currentUserName];
    [responseModel.momentModel addResponseModel:newResponse];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _momentModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JCMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCMomentCell" forIndexPath:indexPath];
    JCMomentsModel *model = _momentModels[indexPath.row];
    [cell setModel:model
         indexPath:indexPath
          delegate:self
headerPlaceholdImage:_headerPlaceholdImage
momentPlaceholdImage:_momentPlaceholdImage];
    cell.clickVideoBlock = _clickVideoBlock;
    cell.commentBackImage = _commentBackImage;
    cell.nameColor = _nameColor;
    cell.textColor = _textColor;
    cell.watchMoreButtonColor = _watchMoreButtonColor;
    cell.addressColor = _addressColor;
    cell.timeColor = _timeColor;
    cell.viewColor = _viewColor;
    cell.headerLayerColor = _headerLayerColor;
    cell.headerborderWidth = _headerborderWidth;
    cell.timeColor = _timeColor;
    cell.viewColor = _viewColor;
    cell.commentCutLineBackColor = _separatorColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    JCMomentsModel *model = _momentModels[indexPath.row];
    return model.showMoreSate == ShowMoreBtnSatePackUp?model.normalCellHeight:model.showMoreCellHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeCancelAllEdit object:nil];
}

#pragma mark - cell代理
- (void)momentCellDidTapAction:(JCMomentCell *)momentCell
                    actionType:(MomentTapActionType)actionType
                    momentMode:(JCMomentsModel *)momentModel
             responseIndexPath:(NSIndexPath *)responseIndex{
    __weak typeof(self)weakSelf = self;
    if (actionType == MomentTapActionTypeHeaderImageView ||
        actionType == MomentTapActionTypeNickNameLabel ||
        actionType == MomentTapActionTypeMomentTextLabel ||
        actionType == MomentTapActionTypeMenuButton ||
        actionType == MomentTapActionTypeLike ||
        actionType == MomentTapActionTypeWatchReport) {
        //        点击头像
        //        点击昵称
        //        点击文本文字
        //        点击右上角菜单
        //        点赞动作
        //        查看训练报告
        if (_delegate && [_delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
            [_delegate didTapAction:self actionType:actionType momentMode:momentModel indexPath:responseIndex inputString:nil];
        }
    }else if (actionType == MomentTapActionTypeMoreButton){
        //        查看更多文字
        [UIView performWithoutAnimation:^{
            [self.tableView reloadRowAtIndexPath:momentModel.indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        if (_delegate && [_delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
            [_delegate didTapAction:self actionType:MomentTapActionTypeMoreButton momentMode:momentModel indexPath:nil inputString:nil];
        }
    }else if (actionType == MomentTapActionTypeComment){
        //        点击评论
        [_inputView editState:YES];
        NSString *placeHold = [NSString stringWithFormat:@"@%@",momentModel.userName];
        [_inputView setPlaceHoldString:placeHold];
        _inputView.inputComplete = ^(NSString *inputString) {
            if (inputString.length > 0) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
                    [weakSelf.delegate didTapAction:weakSelf
                                         actionType:MomentTapActionTypeComment
                                         momentMode:momentModel
                                          indexPath:responseIndex
                                        inputString:inputString];
                }
            }
        };
    }else if (actionType == MomentTapActionTypeReplayComment){
        //        回复评论
        [_inputView editState:YES];
        NSString *placeHold = [NSString stringWithFormat:@"@%@",momentModel.responseList[responseIndex.row].rUserName];
        [_inputView setPlaceHoldString:placeHold];
        _inputView.inputComplete = ^(NSString *inputString) {
            if (inputString.length > 0) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
                    [weakSelf.delegate didTapAction:weakSelf
                                         actionType:MomentTapActionTypeReplayComment
                                         momentMode:momentModel
                                          indexPath:responseIndex
                                        inputString:inputString];
                }
            }
        };
    }else if (actionType == MomentTapActionTypeDeleteComment){
        //删除 评论 或 回复
        if (_delegate && [_delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
            [_delegate didTapAction:self
                         actionType:MomentTapActionTypeDeleteComment
                         momentMode:momentModel
                          indexPath:responseIndex
                        inputString:nil];
        }
    }
}

/**
 查看某个用户详情
 */
- (void)watchUserInfo:(NSNotification *)notice{
    NSDictionary *userDic = notice.userInfo;
    NSString *userID = userDic[@"userID"];
    if (_delegate && [_delegate respondsToSelector:@selector(didTapAction:actionType:momentMode:indexPath:inputString:)]) {
        [_delegate didTapAction:self
                     actionType:MomentTapActionTypeWatchOtherInfo
                     momentMode:nil
                      indexPath:nil
                    inputString:userID];
    }
}

- (void)dealloc{
    [_inputView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

