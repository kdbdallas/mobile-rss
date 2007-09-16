/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#import "EditorKeyboard.h"

#import <UIKit/CDStructures.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIScroller.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UIView-Geometry.h>

//
// Override settings of the default keyboard implementation
//

@interface UIKeyboardImpl : UIView
{

}
@end

@implementation UIKeyboardImpl (DisableFeatures)


- (BOOL)autoCapitalizationPreference
{
  return false;
}

- (BOOL)autoCorrectionPreference
{
  return false;
}

int m_preferredKeyboardType = 1;

@end

//
// EditorKeyboard
//

@implementation EditorKeyboard

- (void) show
{
    [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
    [self setFrame:CGRectMake(0.0f, 480.0, 320.0f, 480.0f)];

    struct CGAffineTransform trans =
	CGAffineTransformMakeTranslation(0, -235);
    UITransformAnimation *translate =
	[[UITransformAnimation alloc] initWithTarget: self];
    [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
    [translate setEndTransform: trans];
    [[[UIAnimator alloc] init] addAnimation:translate
			       withDuration:.5 start:YES];
}

- (void) hide
{
    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
    
    [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
    [self setFrame:CGRectMake(0.0f, 235.0, 320.0f, 480.0f)];
    
    struct CGAffineTransform trans =
	CGAffineTransformMakeTranslation(0, 235);
    UITransformAnimation *translate =
	[[UITransformAnimation alloc] initWithTarget: self];
    [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
    [translate setEndTransform: trans];
    [[[UIAnimator alloc] init] addAnimation:translate
			       withDuration:.5 start:YES];
}


@end
