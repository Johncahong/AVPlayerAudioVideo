//
//  HRLrcManager.m
//  AVPlayer视频和音频播放
//
//  Created by Hello Cai on 2021/9/11.
//

#import "HRLrcManager.h"
#import "HRLrcEach.h"

//匿名类别中声明的成员变量和方法，不对外公开，只能被当前类的成员方法调用。
@implementation HRLrcManager{
    NSMutableArray * _array;    //存储解析得到的单词
}

- (id)initWithFile:(NSString *)path
{
    if (self = [super init]) {
        _array = [[NSMutableArray alloc] init];
        _message = [[HRLrcMessage alloc] init];
        //解析相关路径的文件
        [self paserLrcFile:path];
    }
    return self;
}



//歌词其实就是一个LRC文件，里面存放了所有的歌词
//
//类似于
//[ti:传奇]
//[ar:王菲]
//
//[00:03.50]传奇
//[00:19.10]作词：刘兵 作曲：李健
//[00:20.60]演唱：王菲
//[00:26.60]
//[04:40.75][02:39.90][00:36.25]只是因为在人群中多看了你一眼
//[04:49.00]

//解析相关路径的文件，将歌词存储到数据模型中，再将数据模型存储到数组中
- (void)paserLrcFile:(NSString *)path
{
    //读取文件
    NSString * contents = [self readFile:path];
    //解析歌词内容
    [self paserLrcFileContents:contents];
    //数组排序
    [self sortArray];
}

//读取文件，返回文件内容
- (NSString *)readFile:(NSString *)path
{
    NSString * contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return contents;
}

//解析歌词内容
- (void)paserLrcFileContents:(NSString *)contents
{
    //使用回车分割
    NSArray * contentArray = [contents componentsSeparatedByString:@"\n"];
    //遍历每一行字符串
    for (NSString * content in contentArray) {
        //跳过空字符串
        if ([content isEqualToString:@""] == YES) {
            continue;
        }
        
        //判断这一行是否以@"[0"开头
        if ([content hasPrefix:@"[0"] == YES) {
            //解析这句歌词，存入歌词单句的数据模型中
            [self paserLrcEach:content];
        }else if([content hasPrefix:@"["] == YES){
            [self paserLrcMessage:content];
        }
    }
}

//解析一句歌词，存入数据模型
- (void)paserLrcEach:(NSString *)lrcEach
{
    //字符串分割 以]为分割符
    NSArray * lrcArray = [lrcEach componentsSeparatedByString:@"]"];
    
    
    for (NSString * lrc in lrcArray) {
        if ([lrc hasPrefix:@"["] == YES) {
            //获取秒数
            float seconds = [self sencondsForTime:lrc];
            //创建数据模型
            HRLrcEach * each = [[HRLrcEach alloc] init];
            each.seconds = seconds;
            each.lrcEach = lrcArray[lrcArray.count - 1];
            //将数据模型，存入数组
            [_array addObject:each];
        }
    }
    NSLog(@"%@",_array);
}


//解析曲目的信息
- (void)paserLrcMessage:(NSString *)message
{
    NSArray * messageArray = [message componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[:]"]];
    if ([messageArray[1] isEqualToString:@"ar"]) {
        _message.ar = messageArray[2];
    }else if([messageArray[1] isEqualToString:@"ti"]){
        _message.ti = messageArray[2];
    }else if([messageArray[1] isEqualToString:@"al"]){
        _message.al = messageArray[2];
    }else if([messageArray[1] isEqualToString:@"by"]){
        _message.by = messageArray[2];
    }else if([messageArray[1] isEqualToString:@"offset"]){
        _message.offset = [messageArray[2] floatValue];
    }

}

//给一个时间字符串，返回对应的秒数
- (float)sencondsForTime:(NSString *)time
{   //[00:15.26
    NSArray * timeArray = [time componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[:"]];
    //取出分
    float minute = [timeArray[1] floatValue];
    //取出秒
    float seconds = [timeArray[2] floatValue];
    return minute * 60 + seconds;
}


//数组排序
- (void)sortArray
{
    for (int i = 0; i < _array.count - 1; i++) {
        for (int j = 0; j < _array.count - 1 - i; j++) {
            if ([_array[j] seconds] > [_array[j + 1] seconds]) {
                [_array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
        }
    }
}

- (NSString *)lrcInTime:(float)time
{
    for (NSInteger i = _array.count - 1; i >= 0; i--) {
        if ([_array[i] seconds] < time) {
            return [_array[i] lrcEach];
        }
    }
    return nil;
}


@end
