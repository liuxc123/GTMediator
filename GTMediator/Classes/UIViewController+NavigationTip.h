//
//  UIViewController+NavigationTip.h
//  GTMediator-iOS12.0
//
//  Created by liuxc on 2018/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @category NavigationTip
 *  中间件导航的错误提示
 */
@interface UIViewController (NavigationTip)

/**
 * URL可导航，参数错误无法生成ViewController
 */
+(nonnull UIViewController *) paramsError;

/**
 * URL可导航，但是提供者并没有对URL返回一个ViewController
 */
+(nonnull UIViewController *) notURLController;


/**
 * URL不可导航，提示用户无法通过GTMediator导航
 */
+(nonnull UIViewController *) notFound;

@end

NS_ASSUME_NONNULL_END
