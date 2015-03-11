#import "PreferenceHeaders.h"

@interface ColorBannersPrefsListController : PSListController
@end

@interface ColorBannersBannerPrefsController : PSListController
@end

@interface ColorBannersLSPrefsController : PSListController
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)specifier;
@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView;
@end

@interface ColorBannersHeaderCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *_titleLabel;
	UILabel *_subtitleLabel;
}
@end
