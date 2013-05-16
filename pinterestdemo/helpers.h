#define UIColorFromRGB(rgbValue) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ARC4RANDOM_MAX      0x100000000

static CGFloat const kNavigationBarPortraitHeight = 44;
static CGFloat const kNavigationBarLandscapeHeight = 34;
static NSString *const kImageBaseURL = @"http://media-cache-ec2.pinimg.com/";