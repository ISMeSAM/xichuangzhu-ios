//
//  XCZAuthorDetailsViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-4.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthorDetailsViewController.h"
#import <FMDB/FMDB.h>
#import "XCZWork.h"
#import "XCZAuthor.h"
#import "XCZWorkDetailViewController.h"

@interface XCZAuthorDetailsViewController ()

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *periodField;
@property (weak, nonatomic) IBOutlet UILabel *introField;
@property (weak, nonatomic) IBOutlet UILabel *worksHeaderField;

@end

@implementation XCZAuthorDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nameField.text = self.author.name;
    
    // 时期
    NSLog(@"%@", self.author.name);
    if (![self.author.deathYear isEqualToString:@""]) {
        self.periodField.text = [[NSString alloc] initWithFormat:@"[%@]  %@ ~ %@", self.author.dynasty, self.author.birthYear, self.author.deathYear];
    } else {
        self.periodField.text = [[NSString alloc] initWithFormat:@"[%@]", self.author.dynasty];
    }

    // 简介
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineHeightMultiple = 1.3;
    self.introField.attributedText = [[NSAttributedString alloc] initWithString:self.author.intro attributes:@{NSParagraphStyleAttributeName: contentParagraphStyle}];
    
    // 作品数目
    self.worksHeaderField.text = [[NSString alloc] initWithFormat:@"作品 / %d", self.works.count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.author.name;
    UIView *headerView = self.headerView;
    [self.tableView setTableHeaderView:headerView];

    // 计算introLabel的高度
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineHeightMultiple = 1.3;
    CGRect introSize = [self.author.intro
                           boundingRectWithSize:CGSizeMake(285.f, CGFLOAT_MAX)
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName: self.introField.font,
                                        NSParagraphStyleAttributeName: contentParagraphStyle}
                           context:nil];
    CGFloat height = self.introField.frame.origin.y + introSize.size.height;
    
    
    height += 15;
    height += self.worksHeaderField.frame.size.height;
    height += 2;
    
    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = height;
    headerView.frame = headerFrame;

    [self.tableView setTableHeaderView:headerView];
}

- (UIView *)headerView
{
    if(!_headerView){
        [[NSBundle mainBundle] loadNibNamed:@"AuthorHeaderView" owner:self options:nil];
    }
    
    return _headerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.works.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = [self.works[indexPath.row] title];
    return cell;
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWorkDetailViewController *detailController = [[XCZWorkDetailViewController alloc] init];
    XCZWork *work = self.works[indexPath.row];
    detailController.work = work;
    [self.navigationController pushViewController:detailController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end