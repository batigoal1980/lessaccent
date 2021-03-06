//
//  ISESettingViewController.m
//  MSCDemo_UI
//
//  Created by 张剑 on 15/1/16.
//
//

#import "ISESettingViewController.h"
#import "ISEParams.h"
#import "PopupView.h"

#pragma mark - const values

int const KCSectionCount=1;
int const KCCellCount=6;
NSString* const KCCellIdentifier=@"ISESettingCell";

NSString* const KCCancelBtnTitle=@"Cancel";
NSString* const KCOkBtnTitle=@"Okay";

#pragma mark -

@interface ISESettingViewController () 

@property (nonatomic, strong) PopupView* popView;

@end


@implementation ISESettingViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
	
    //set TableView DataSource
	self.iseParams = [ISEParams fromUserDefaults];

	return [super initWithStyle:style];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];

    //popupView
    self.popView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    self.popView.ParentView = self.view;
    
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)reloadData {
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    [self.iseParams toUserDefaults];
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(onParamsChanged:)]) {
		[self.delegate onParamsChanged:self.iseParams];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return KCSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return KCCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:KCCellIdentifier];
	}
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = KCLanguageTitle;
            cell.detailTextLabel.text = self.iseParams.languageShow;
        }
            break;
        case 1:{
            cell.textLabel.text = KCCategoryTitle;
            cell.detailTextLabel.text = self.iseParams.categoryShow;
        }
            break;
        case 2:{
            cell.textLabel.text = KCRstLevelTitle;
            cell.detailTextLabel.text = self.iseParams.rstLevel;
        }
            break;
        case 3:{
            cell.textLabel.text = KCBOSTitle;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ms",self.iseParams.bos];
        }
            break;
        case 4:{
            cell.textLabel.text = KCEOSTitle;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ms",self.iseParams.eos];
        }
            break;
        case 5:{
            cell.textLabel.text = KCTimeoutTitle;
            int value=[self.iseParams.timeout intValue];
            if( value >= 0 ){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ms",self.iseParams.timeout];
            }
            else{
                cell.detailTextLabel.text = self.iseParams.timeout;
            }
            
        }
            break;
            
        default:
            break;
    }
	
	cell.detailTextLabel.textColor = [UIColor colorWithRed:28 / 255.0f green:160 / 255.0f blue:170 / 255.0f alpha:1.0];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	switch (indexPath.row) {
		case 0: {
			NSString *title = KCLanguageTitle;
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
			                                                         delegate:self
			                                                cancelButtonTitle:nil
			                                           destructiveButtonTitle:nil
			                                                otherButtonTitles:nil, nil];
			actionSheet.tag = indexPath.row;
            if(![self.iseParams.rstLevel isEqualToString:KCRstLevelPlain]){//中文不支持plain
                [actionSheet addButtonWithTitle:KCLanguageShowZHCN];
            }
            if(![self.iseParams.category isEqualToString:KCCategorySyllable]){//英文不支持单字
                [actionSheet addButtonWithTitle:KCLanguageShowENUS];
            }
			
			actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:KCCancelBtnTitle];
			[actionSheet showInView:self.view];
		}
		break;

		case 1: {
            NSString *title = KCCategoryTitle;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil, nil];
            actionSheet.tag = indexPath.row;
            [actionSheet addButtonWithTitle:KCCategoryShowSentence];
            [actionSheet addButtonWithTitle:KCCategoryShowWord];
            [actionSheet addButtonWithTitle:KCCategoryShowWord2];
            if(![self.iseParams.language isEqualToString:KCLanguageENUS]){//英文不支持单字
                [actionSheet addButtonWithTitle:KCCategoryShowSyllable];
            }

            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:KCCancelBtnTitle];
            [actionSheet showInView:self.view];

		}
		break;

		case 2: {
			NSString *title = KCRstLevelTitle;
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
			                                                         delegate:self
			                                                cancelButtonTitle:nil
			                                           destructiveButtonTitle:nil
			                                                otherButtonTitles:nil, nil];
			actionSheet.tag = indexPath.row;
            
            if(![self.iseParams.language isEqualToString:KCLanguageZHCN]){//中文不支持plain格式
                [actionSheet addButtonWithTitle:KCRstLevelPlain];
            }
            
            [actionSheet addButtonWithTitle:KCRstLevelComplete];

			actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:KCCancelBtnTitle];
			[actionSheet showInView:self.view];
		}
		break;

		case 3: {
			NSString *title = KCBOSTitle;
			NSString *message = @"";
			NSString *btnOkTitle = KCOkBtnTitle;
			NSString *btnCancelTitle = KCCancelBtnTitle;
			NSString *placeholderText = @"";

			float version = [[[UIDevice currentDevice] systemVersion] floatValue];
			if (version > 8.0) {
				UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
				                                                                         message:message
				                                                                  preferredStyle:UIAlertControllerStyleAlert];
				[alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
				    NSString *defValue = self.iseParams.bos;
				    if (!defValue) {
				        defValue = placeholderText;
					}
				    textField.font = [UIFont systemFontOfSize:9];
				    textField.text = defValue;
                    textField.keyboardType=UIKeyboardTypeNumberPad;
                    textField.tag=0;
                    textField.delegate=self;
				}];
				UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:btnCancelTitle
				                                                       style:UIAlertActionStyleCancel
				                                                     handler: ^(UIAlertAction *action) {
				}];
				UIAlertAction *okAction = [UIAlertAction actionWithTitle:btnOkTitle
				                                                   style:UIAlertActionStyleDefault
				                                                 handler: ^(UIAlertAction *action) {
				    UITextField *textField = alertController.textFields.firstObject;
                    if(textField.text){
                        int value=[textField.text intValue];
                        if([textField.text length]<1){
                            [self.popView setText:@"取值不能为空"];
                            [self.view addSubview:self.popView];
                        }
                        else if(value>=0 && value<=30000){
                            self.iseParams.bos = textField.text;
                        }else{
                            [self.popView setText:@"取值范围为：0~30000"];
                            [self.view addSubview:self.popView];
                        }
                        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }
                    else{
                        [self.popView setText:@"未知错误"];
                        [self.view addSubview:self.popView];
                    }

				}];
				[alertController addAction:cancelAction];
				[alertController addAction:okAction];
				[self presentViewController:alertController animated:YES completion:nil];
			}
			else {
				UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
				                                                    message:message
				                                                   delegate:self
				                                          cancelButtonTitle:btnCancelTitle
				                                          otherButtonTitles:btnOkTitle, nil];
				alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
				UITextField *textField = [alertview textFieldAtIndex:0];
                textField.keyboardType=UIKeyboardTypeNumberPad;
                textField.delegate=self;
                textField.tag=0;
				alertview.tag = indexPath.row;
				NSString *defValue = self.iseParams.bos;
				if (!defValue) {
					defValue = placeholderText;
				}
				textField.font = [UIFont systemFontOfSize:9];
				textField.text = defValue;
				[alertview show];
			}
		}
		break;

		case 4: {
			NSString *title = KCEOSTitle;
			NSString *message = @"";
			NSString *btnOkTitle = KCOkBtnTitle;
			NSString *btnCancelTitle = KCCancelBtnTitle;
			NSString *placeholderText = @"";

			float version = [[[UIDevice currentDevice] systemVersion] floatValue];
			if (version > 8.0) {
				UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
				                                                                         message:message
				                                                                  preferredStyle:UIAlertControllerStyleAlert];
				[alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
				    NSString *defValue = self.iseParams.eos;
				    if (!defValue) {
				        defValue = placeholderText;
					}
				    textField.font = [UIFont systemFontOfSize:9];
				    textField.text = defValue;
                    textField.keyboardType=UIKeyboardTypeNumberPad;
                    textField.delegate=self;
                    textField.tag=1;
				}];
				UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:btnCancelTitle
				                                                       style:UIAlertActionStyleCancel
				                                                     handler: ^(UIAlertAction *action) {
				}];
				UIAlertAction *okAction = [UIAlertAction actionWithTitle:btnOkTitle
				                                                   style:UIAlertActionStyleDefault
				                                                 handler: ^(UIAlertAction *action) {
				    UITextField *textField = alertController.textFields.firstObject;
                     if(textField.text){
                         int value=[textField.text intValue];
                         if([textField.text length]<1){
                             [self.popView setText:@"取值不能为空"];
                             [self.view addSubview:self.popView];
                         }
                         else if(value>=0 && value<=30000){
                             self.iseParams.eos = textField.text;
                         }else{
                             [self.popView setText:@"取值范围为：0~30000"];
                             [self.view addSubview:self.popView];
                         }
                         [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                     }
                     else{
                         [self.popView setText:@"未知错误"];
                         [self.view addSubview:self.popView];
                     }
				}];
				[alertController addAction:cancelAction];
				[alertController addAction:okAction];
				[self presentViewController:alertController animated:YES completion:nil];
			}
			else {
				UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
				                                                    message:message
				                                                   delegate:self
				                                          cancelButtonTitle:btnCancelTitle
				                                          otherButtonTitles:btnOkTitle, nil];
				alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
				UITextField *textField = [alertview textFieldAtIndex:0];
                textField.keyboardType=UIKeyboardTypeNumberPad;
                textField.delegate=self;
                textField.tag=1;
				alertview.tag = indexPath.row;
				NSString *defValue = self.iseParams.eos;
				if (!defValue) {
					defValue = placeholderText;
				}
				textField.font = [UIFont systemFontOfSize:9];
				textField.text = defValue;
				[alertview show];
			}
		}
		break;

		case 5: {
			NSString *title = KCTimeoutTitle;
			NSString *message = @"";
			NSString *btnOkTitle = KCOkBtnTitle;
			NSString *btnCancelTitle = KCCancelBtnTitle;
			NSString *placeholderText = @"";

			float version = [[[UIDevice currentDevice] systemVersion] floatValue];
			if (version > 8.0) {
				UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
				                                                                         message:message
				                                                                  preferredStyle:UIAlertControllerStyleAlert];
				[alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
				    NSString *defValue = self.iseParams.timeout;
				    if (!defValue) {
				        defValue = placeholderText;
					}
				    textField.font = [UIFont systemFontOfSize:9];
				    textField.text = defValue;
                    textField.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                    textField.delegate=self;
                    textField.tag=2;
				}];
				UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:btnCancelTitle
				                                                       style:UIAlertActionStyleCancel
				                                                     handler: ^(UIAlertAction *action) {
				}];
				UIAlertAction *okAction = [UIAlertAction actionWithTitle:btnOkTitle
				                                                   style:UIAlertActionStyleDefault
				                                                 handler: ^(UIAlertAction *action) {
				    UITextField *textField = alertController.textFields.firstObject;
                    
                     if(textField.text){
                         int value=[textField.text intValue];
                         if([textField.text length]<1){
                             [self.popView setText:@"取值不能为空"];
                             [self.view addSubview:self.popView];
                         }
                         else if(value>=-1){
                             self.iseParams.timeout = textField.text;
                         }else{
                             [self.popView setText:@"取值范围为：大于等于-1"];
                             [self.view addSubview:self.popView];
                         }
                         [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                     }
                     else{
                         [self.popView setText:@"未知错误"];
                         [self.view addSubview:self.popView];
                     }
				}];
				[alertController addAction:cancelAction];
				[alertController addAction:okAction];
				[self presentViewController:alertController animated:YES completion:nil];
			}
			else {
				UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
				                                                    message:message
				                                                   delegate:self
				                                          cancelButtonTitle:btnCancelTitle
				                                          otherButtonTitles:btnOkTitle, nil];
				alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
				UITextField *textField = [alertview textFieldAtIndex:0];
                textField.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                textField.delegate=self;
                textField.tag=2;
				alertview.tag = indexPath.row;
				NSString *defValue = self.iseParams.timeout;
				if (!defValue) {
					defValue = placeholderText;
				}
				textField.font = [UIFont systemFontOfSize:9];
				textField.text = defValue;
				[alertview show];
			}
		}
		break;

		default:
			break;
	}
}

#pragma mark  UIActionSheetDelegate

/**
 * @fn      actionSheet
 * @brief  设置引擎 and 选择发音人
 *
 * @see
 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (actionSheet.tag) {
		case 0: {//
			switch (buttonIndex) {
				case 0: {
                    if(![self.iseParams.rstLevel isEqualToString:KCRstLevelPlain]){//中文不支持plain
                        self.iseParams.language = KCLanguageZHCN;
                        self.iseParams.languageShow = KCLanguageShowZHCN;
                    }
                    else{
                        self.iseParams.language = KCLanguageENUS;
                        self.iseParams.languageShow = KCLanguageShowENUS;
                    }
				}
				break;

				case 1: {
                    if(![self.iseParams.category isEqualToString:KCCategorySyllable]){//英文不支持单字
                        self.iseParams.language = KCLanguageENUS;
                        self.iseParams.languageShow = KCLanguageShowENUS;
                    }
				}
				break;
			}
		}
		break;

		case 1: {//
			switch (buttonIndex) {
                case 0: {
                    self.iseParams.category = KCCategorySentence;
                    self.iseParams.categoryShow = KCCategoryShowSentence;
                }
                    break;
                    
				case 1: {
                    self.iseParams.category = KCCategoryWord;
                    self.iseParams.categoryShow = KCCategoryShowWord;
				}
				break;
                    
                case 2: {
                    self.iseParams.category = KCCategoryWord2;
                    self.iseParams.categoryShow = KCCategoryShowWord2;
                }
                    break;

                case 3: {
                    if(![self.iseParams.language isEqualToString:KCLanguageENUS]){//英文不支持单字
                        self.iseParams.category = KCCategorySyllable;
                        self.iseParams.categoryShow = KCCategoryShowSyllable;
                    }
                }
                    break;
			
			}
		}
		break;

		case 2: {//
			switch (buttonIndex) {
				case 0: {
                     if([self.iseParams.language isEqualToString:KCLanguageENUS]){//中文不支持plain
                        self.iseParams.rstLevel = KCRstLevelPlain;
                     }
                     else{
                         self.iseParams.rstLevel = KCRstLevelComplete;
                     }
				}
				break;

				case 1: {
					self.iseParams.rstLevel = KCRstLevelComplete;
				}
				break;
			}
		}
		break;
	}
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case 3: {
			switch (buttonIndex) {
				case 1: {
					UITextField *textField = [alertView textFieldAtIndex:0];
                    
                    if(textField.text){
                        int value=[textField.text intValue];
                        if([textField.text length]<1){
                            [self.popView setText:@"取值不能为空"];
                            [self.view addSubview:self.popView];
                        }
                        else if(value>=0 && value<=30000){
                            self.iseParams.bos = textField.text;
                        }else{
                            [self.popView setText:@"取值范围为：0~30000"];
                            [self.view addSubview:self.popView];
                        }
                        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }
                    else{
                        [self.popView setText:@"未知错误"];
                        [self.view addSubview:self.popView];
                    }
				}
				break;

				default:
					break;
			}
		}
		break;

		case 4: {
			switch (buttonIndex) {
				case 1: {
					UITextField *textField = [alertView textFieldAtIndex:0];
                    if(textField.text){
                        int value=[textField.text intValue];
                        if([textField.text length]<1){
                            [self.popView setText:@"取值不能为空"];
                            [self.view addSubview:self.popView];
                        }
                        else if(value>=0 && value<=30000){
                            self.iseParams.eos = textField.text;
                        }else{
                            [self.popView setText:@"取值范围为：0~30000"];
                            [self.view addSubview:self.popView];
                        }
                        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }
                    else{
                        [self.popView setText:@"未知错误"];
                        [self.view addSubview:self.popView];
                    }
				}
				break;

				default:
					break;
			}
		}
		break;

		case 5: {
			switch (buttonIndex) {
				case 1: {
					UITextField *textField = [alertView textFieldAtIndex:0];
                    
                    if(textField.text){
                        int value=[textField.text intValue];
                        if([textField.text length]<1){
                            [self.popView setText:@"取值不能为空"];
                            [self.view addSubview:self.popView];
                        }
                        else if(value>=-1){
                            self.iseParams.timeout = textField.text;
                        }else{
                            [self.popView setText:@"取值范围为：大于等于-1"];
                            [self.view addSubview:self.popView];
                        }
                        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }
                    else{
                        [self.popView setText:@"未知错误"];
                        [self.view addSubview:self.popView];
                    }
				}
				break;

				default:
					break;
			}
		}
		break;

		default:
			break;
	}
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}


#pragma mark - textField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL isValid=YES;
    
    if(textField.tag<2){
        NSCharacterSet* validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        int  i=0;
        while(i<string.length){
            NSString * subStr= [string substringWithRange:NSMakeRange(i, 1)];
            NSRange subRange = [subStr rangeOfCharacterFromSet:validSet];
            if (subRange.length == 0) {
                isValid = NO;
                break;
            }
            i++;
        }
    }
    else{
        NSCharacterSet* validFSet = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789"];
        NSCharacterSet* validOSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        int  i=0;
        while(i<string.length){
            NSString * subStr= [string substringWithRange:NSMakeRange(i, 1)];
            NSRange subRange;
            if(0==i && range.location==0){
                subRange = [subStr rangeOfCharacterFromSet:validFSet];
            }else{
                subRange = [subStr rangeOfCharacterFromSet:validOSet];
            }
            if (subRange.length == 0) {
                isValid = NO;
                break;
            }
            i++;
        }
    }
    return isValid;
}

@end
