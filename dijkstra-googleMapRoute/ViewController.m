//
//  ViewController.m
//  dijkstra-googleMapRoute
//
//  Created by JINGLUO on 15/4/25.
//  Copyright (c) 2015年 JINGLUO. All rights reserved.
//

#import "ViewController.h"

#define MAXNUM 0xFFFFFF

@interface ViewController () <UITextFieldDelegate> {
    UIScrollView *mScrollView;
    UIImageView *mapImageView;
    GeoView *routeView;
    
    NSArray *pointsArray;  // 50个道路节点
    NSArray *routesArray;  // 每个节点可通往的下一节点的合集
    NSMutableArray *edgeArray;  // 点于点的距离
    NSMutableArray *tempArray;  // 纪录该点有没有被放入最短距离的节点集合中,相当于记录最短路径的各个节点
    NSMutableArray *distArray;  // 最终的某两点间的最短距离
    NSMutableArray *resultArray;  // 两点间最短路径的节点集合
    
    NSInteger N; // 总的节点数
    NSInteger stNum, edNum;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [mScrollView setContentSize:CGSizeMake(1227, 1000)];
//    mScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"googleMap.png"]];
    [self.view addSubview:mScrollView];
    
    mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1227, 565)];
    [mapImageView setImage:[UIImage imageNamed:@"googleMap.png"]];
    [mScrollView addSubview:mapImageView];
    
    //  画出道路上的各个节点
    pointsArray = [[NSArray alloc] init];
    pointsArray = @[[NSValue valueWithCGPoint:CGPointMake(48, 100)], [NSValue valueWithCGPoint:CGPointMake(33, 195)],
                    [NSValue valueWithCGPoint:CGPointMake(23, 270)], [NSValue valueWithCGPoint:CGPointMake(160, 121)],
                    // 1-8
                    [NSValue valueWithCGPoint:CGPointMake(140, 209)], [NSValue valueWithCGPoint:CGPointMake(358, 248)],
                    [NSValue valueWithCGPoint:CGPointMake(125, 280)], [NSValue valueWithCGPoint:CGPointMake(95, 450)],
                    
                    [NSValue valueWithCGPoint:CGPointMake(315, 490)], [NSValue valueWithCGPoint:CGPointMake(395, 70)],
                    [NSValue valueWithCGPoint:CGPointMake(405, 20)], [NSValue valueWithCGPoint:CGPointMake(450, 65)],
                    //9-16
                    [NSValue valueWithCGPoint:CGPointMake(475, 185)], [NSValue valueWithCGPoint:CGPointMake(500, 280)],
                    [NSValue valueWithCGPoint:CGPointMake(535, 365)], [NSValue valueWithCGPoint:CGPointMake(507, 520)],
                    
                    [NSValue valueWithCGPoint:CGPointMake(345, 333)], [NSValue valueWithCGPoint:CGPointMake(335, 390)],
                    [NSValue valueWithCGPoint:CGPointMake(610, 440)], [NSValue valueWithCGPoint:CGPointMake(640, 125)],
                    //17-24
                    [NSValue valueWithCGPoint:CGPointMake(660, 205)], [NSValue valueWithCGPoint:CGPointMake(700, 260)],
                    [NSValue valueWithCGPoint:CGPointMake(730, 145)], [NSValue valueWithCGPoint:CGPointMake(645, 355)],
                    
                    [NSValue valueWithCGPoint:CGPointMake(522, 428)], [NSValue valueWithCGPoint:CGPointMake(830, 170)],
                    [NSValue valueWithCGPoint:CGPointMake(820, 280)], [NSValue valueWithCGPoint:CGPointMake(760, 340)],
                    //25-32
                    [NSValue valueWithCGPoint:CGPointMake(735, 390)], [NSValue valueWithCGPoint:CGPointMake(800, 385)],
                    [NSValue valueWithCGPoint:CGPointMake(720, 465)], [NSValue valueWithCGPoint:CGPointMake(730, 550)],
                    
                    [NSValue valueWithCGPoint:CGPointMake(910, 180)], [NSValue valueWithCGPoint:CGPointMake(890, 290)],
                    [NSValue valueWithCGPoint:CGPointMake(867, 400)], [NSValue valueWithCGPoint:CGPointMake(850, 505)],
                    //33-40
                    [NSValue valueWithCGPoint:CGPointMake(1020, 200)], [NSValue valueWithCGPoint:CGPointMake(1000, 310)],
                    [NSValue valueWithCGPoint:CGPointMake(922, 295)], [NSValue valueWithCGPoint:CGPointMake(980, 420)],
                    
                    [NSValue valueWithCGPoint:CGPointMake(985, 370)], [NSValue valueWithCGPoint:CGPointMake(960, 530)],
                    [NSValue valueWithCGPoint:CGPointMake(580, 350)], [NSValue valueWithCGPoint:CGPointMake(635, 400)],
                    //41-48
                    [NSValue valueWithCGPoint:CGPointMake(1020, 545)], [NSValue valueWithCGPoint:CGPointMake(1040, 430)],
                    [NSValue valueWithCGPoint:CGPointMake(1090, 440)], [NSValue valueWithCGPoint:CGPointMake(1100, 400)],
                    
                    // 49-50
                    [NSValue valueWithCGPoint:CGPointMake(1110, 330)], [NSValue valueWithCGPoint:CGPointMake(1130, 220)]];
    
    for (int i = 0; i < pointsArray.count; i ++) {
        CGPoint pointValue = [[pointsArray objectAtIndex:i] CGPointValue];
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(pointValue.x, pointValue.y, 15, 15)];
        pointLabel.layer.masksToBounds = YES;
        pointLabel.layer.cornerRadius = 8;
        pointLabel.backgroundColor = [UIColor colorWithRed:252/255.0f green:13/255.0f blue:27/255.0f alpha:0.6];
        pointLabel.text = [NSString stringWithFormat:@"%d", i];
        pointLabel.textAlignment = NSTextAlignmentCenter;
        pointLabel.adjustsFontSizeToFitWidth = YES;
        [mapImageView addSubview:pointLabel];
    }
    
    
    // 每个点可以通往的下一个点合集，有些道路为one way，则车子无法通过
    routesArray = [[NSArray alloc] init];
    routesArray = @[@[@"1", @"3"], @[@"0", @"2", @"4"], @[@"1", @"8"], @[@"0", @"4"],
                    //1-8
                    @[@"1", @"3", @"5", @"6"], @[@"4", @"9", @"13", @"16"], @[@"2", @"4", @"7"], @[@"6", @"8"],
                
                    @[@"7", @"15", @"17"], @[@"5", @"10"], @[@"11"], @[@"9", @"12", @"19"],
                    //9-16
                    @[@"11", @"13", @"20"], @[@"5", @"12", @"14"], @[@"13", @"16", @"18", @"24", @"42"], @[@"8", @"24", @"31"],
                    
                    @[@"5", @"14", @"17"], @[@"8", @"16", @"24"], @[@"14", @"24", @"43", @"30"], @[@"11", @"20", @"22"],
                    //17-24
                    @[@"12", @"19", @"21"], @[@"20", @"26", @"27", @"42"], @[@"19", @"25"], @[@"28", @"43"],
                    
                    @[@"14", @"15", @"17", @"18"], @[@"22", @"26", @"32"], @[@"21", @"25", @"29", @"33"], @[@"21", @"28", @"29"],
                    //25-32
                    @[@"23", @"27", @"29", @"30"], @[@"26", @"27", @"28", @"34"], @[@"18", @"28", @"31", @"35"], @[@"15", @"30"],

                    @[@"25", @"33", @"36"], @[@"26", @"32", @"34", @"38"], @[@"29", @"33", @"35", @"39"], @[@"30", @"34", @"41"],
                    //33-40
                    @[@"32", @"37", @"49"], @[@"36", @"38", @"40", @"48"], @[@"33", @"37", @"40"], @[@"34", @"40", @"41", @"45"],

                    @[@"37", @"38", @"39", @"47"], @[@"35", @"39", @"44"], @[@"14", @"21", @"43"], @[@"18", @"23", @"42"],
                    //41-48
                    @[@"41", @"45"], @[@"39", @"44", @"46"], @[@"45", @"47"], @[@"40", @"46", @"48"],

                    //49-50
                    @[@"37", @"47", @"49"], @[@"36", @"48"]];
    
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(mapImageView.frame)+10, 800, 20)];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.text = @"Calculate the shortest route from startPoint to endPoint by Dijkstra Algorithm";
    titleLab.font = [UIFont systemFontOfSize:15];
    [mScrollView addSubview:titleLab];
    
    UILabel *stLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLab.frame)+10, 80, 20)];
    stLab.backgroundColor = [UIColor clearColor];
    stLab.text = @"startPoint: ";
    stLab.font = [UIFont systemFontOfSize:12];
    [mScrollView addSubview:stLab];
    UITextField *stTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(stLab.frame)+5, 80, 30)];
    stTextField.tag = 1;
    stTextField.delegate = self;
    stTextField.borderStyle = UITextBorderStyleRoundedRect;
    stTextField.keyboardType = UIKeyboardTypeNumberPad;
    [mScrollView addSubview:stTextField];

    UILabel *edLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stLab.frame)+10, stLab.frame.origin.y, 80, 20)];
    edLab.backgroundColor = [UIColor clearColor];
    edLab.text = @"endPoint:";
    edLab.font = [UIFont systemFontOfSize:12];
    [mScrollView addSubview:edLab];
    UITextField *edTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stLab.frame)+10, CGRectGetMaxY(edLab.frame)+5, 80, 30)];
    edTextField.tag = 2;
    edTextField.delegate = self;
    edTextField.borderStyle = UITextBorderStyleRoundedRect;
    edTextField.keyboardType = UIKeyboardTypeNumberPad;
    [mScrollView addSubview:edTextField];

    
    UIButton *calculateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    calculateButton.frame = CGRectMake(260, CGRectGetMaxY(titleLab.frame)+20, 100, 40);
    [calculateButton setTitle:@"start calculate" forState:UIControlStateNormal];
    [calculateButton addTarget:self action:@selector(startCalculateAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [mScrollView addSubview:calculateButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)startCalculateAction:(id)sender {
    [self.view endEditing:YES];
    [mScrollView setContentOffset:CGPointMake(0, 0)];

    // 每次都必须初始化所有数据，不然会出错
    distArray = [[NSMutableArray alloc] initWithCapacity:1000];
    resultArray = [[NSMutableArray alloc] initWithCapacity:1000];
    
    // 各点间的距离
    edgeArray = [[NSMutableArray alloc] initWithCapacity:10005];
    tempArray = [[NSMutableArray alloc] initWithCapacity:10005];
    NSInteger i , j , a , b;
    double distantValue;
    N = pointsArray.count;
    for( i = 0 ; i < N ; i ++ )
    {
        [tempArray addObject:[NSNumber numberWithInt:0]];
        NSMutableArray *tempEdgeArray = [[NSMutableArray alloc] initWithCapacity:50];
        for( j = 0 ; j < N ; j ++ ) {
            [tempEdgeArray addObject:[NSNumber numberWithInt:MAXNUM]];
        }
        [edgeArray addObject:tempEdgeArray];
    }
    for( i = 0; i < routesArray.count; i ++ )
    {
        a = i;
        NSArray *tempPointsArray = [[NSArray alloc] init];
        tempPointsArray = [routesArray objectAtIndex:i];
        for (j = 0; j < tempPointsArray.count; j ++) {
            b = [[tempPointsArray objectAtIndex:j] integerValue];
            CGPoint st = [[pointsArray objectAtIndex:a] CGPointValue];
            CGPoint ed = [[pointsArray objectAtIndex:b] CGPointValue];
            distantValue = (st.x-ed.x)*(st.x-ed.x)+(st.y-ed.y)*(st.y-ed.y);
            
            if (distantValue < [edgeArray[a][b] integerValue]) {
                edgeArray[a][b] = [NSNumber numberWithDouble:distantValue];
            }
        }
    }
    
    
    for (i = 0; i < N; i ++) {
        [resultArray addObject:[[NSMutableArray alloc] initWithCapacity:100]];
    }
    
    // 进行dijkstra算法找出最短路径
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"The shortest distant from point%ld to point%ld is", (long)stNum, (long)edNum] message:[NSString stringWithFormat:@"%lf", [self DijkstraWithStartPoint:stNum endPoint:edNum]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    if (stNum > 7 || stNum == 5) {
        CGPoint pointValue = [[pointsArray objectAtIndex:stNum] CGPointValue];
        [mScrollView setContentOffset:CGPointMake(pointValue.x-100, 0)];
    }
    
    [routeView removeFromSuperview];
    // 画出路线
    routeView = [[GeoView alloc] initWithFrame:CGRectMake(0, 0, mapImageView.frame.size.width, mapImageView.frame.size.height)];
    routeView.backgroundColor = [UIColor clearColor];
    routeView.delegate = self;
    [mapImageView addSubview:routeView];
}

#pragma mark - UITextFieldDelegate 

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [mScrollView setContentOffset:CGPointMake(0, 400)];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [mScrollView setContentOffset:CGPointMake(0, 0)];
    
    if (textField.tag == 1) {
        stNum = [textField.text integerValue];
    } else {
        edNum = [textField.text integerValue];
    }
    
    return YES;
}

#pragma mark - dijkstra算法

- (CGFloat)DijkstraWithStartPoint:(NSInteger)startPoint endPoint:(NSInteger)endPoint {
    NSInteger i, j, t = 0;
    for( i = 0 ; i < N ; i ++ )
    {
        [distArray addObject:edgeArray[startPoint][i]];   // 初始化 起点到每一个点的最短距离
        [resultArray[i] addObject:[NSNumber numberWithInteger:startPoint]];  // 将节点添加到最短路径中
    }
    tempArray[startPoint] = [NSNumber numberWithInt:1];  // 记录起点已经使用过
    NSInteger nn = N - 1;
    while( nn -- )
    {
        int minn = MAXNUM ;
        for( i = 0 ; i < N ; i ++ )
        {
            if( [tempArray[i] intValue] != 1 && [distArray[i] doubleValue] < minn )
            {
                minn = [distArray[i] doubleValue] ;
                t = i ;
            }
        }
        tempArray[t] = [NSNumber numberWithInt:1];   // 记录t点已经使用过,并且已经找到从起点到t点的最短路径
        [resultArray[t] addObject:[NSNumber numberWithInteger:t]];  // 将节点添加到最短路径中

        for( i = 0; i < N ; i ++ )
        {
            if( [tempArray[i] intValue] != 1 && [distArray[i] doubleValue] > [edgeArray[t][i] doubleValue] + [distArray[t] doubleValue] )
            {
                distArray[i] = [NSNumber numberWithDouble:[edgeArray[t][i] doubleValue] + [distArray[t] doubleValue]];
                
                // 将节点添加到最短路径中
                [resultArray[i] removeAllObjects];
                NSArray *array = resultArray[t];
                for (j = 0; j < array.count; j ++) {
                    [resultArray[i] addObject:[array objectAtIndex:j]];
                }
            }
        }
    }
    return sqrt([distArray[endPoint] doubleValue]);
}


#pragma mark - GeoViewDelgate Methods

- (void)drawRectByCustom:(GeoView *)geoView {
    NSArray *array = resultArray[edNum];
    // 在地图上绘制最短路径线路
    for (NSInteger i = 0; i < array.count-1; i ++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 4.0);
        
        //画笔设置为红色（包括比划颜色即轮廓的颜色，填充颜色用于填充形状）
        
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        
        //将当前路径的端点移动到该位置，无需实际绘制任何图形。
        
        CGPoint st = [[pointsArray objectAtIndex:[[array objectAtIndex:i] integerValue]] CGPointValue];
        CGContextMoveToPoint(context, st.x, st.y);
        
        //绘制一条线到（ed.x, ed.y）
        
        CGPoint ed = [[pointsArray objectAtIndex:[[array objectAtIndex:i+1] integerValue]] CGPointValue];
        CGContextAddLineToPoint(context, ed.x, ed.y);
        
        //告知Quartz使用CGContextStrokePath绘制直线。
        
        CGContextStrokePath(context);
    }
}

@end
