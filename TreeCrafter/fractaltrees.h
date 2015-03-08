//
//  fractaltrees.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef Fractal_Trees_fractaltrees_h
#define Fractal_Trees_fractaltrees_h

#include "text_strings.h"

#define MAX_LEVELS              32
#define MAX_STAMPS              100
#define VERTEX_TARGET           1000000     // total number we want to submit

#define POPOVER_WIDTH       320
#define POPOVER_HEIGHT      660

#define IMAGE_SAVE_WIDTH               2048
#define IMAGE_SAVE_HEIGHT              1536
#define IMAGE_SAVE_WIDTH_HIGHDETAIL    3264
#define IMAGE_SAVE_HEIGHT_HIGHDETAIL   2448

#define MAX_SAVED_TREES     100
#define TREE_FILE           @"trees.plist"
#define CURRENT_TREE_FILE   @"current.plist"
#define TREE_ICON_WIDTH     180 //280
#define TREE_ICON_HEIGHT    180

#define ANIMATION_DELAY     0.05f

#define SLIDER_CELL             0
#define STEPPER_CELL            1
#define OPTION_CELL             2
#define COLOR_CELL              3
#define BUTTON_CELL             4

#define QUALITY_NORMAL          0
#define QUALITY_ICON            1
#define QUALITY_HIGHDETAIL      2
#define QUALITY_EMAIL           3
#define QUALITY_SOCIAL          4

#define CELL_DEFAULT_HEIGHT     44
#define CELL_STEPPER_HEIGHT     70
#define CELL_SLIDER_HEIGHT      66
#define CELL_ANIM_HEIGHT        130

#define SHAREMODE_CAMERAROLL    0
#define SHAREMODE_EMAIL         1
#define SHAREMODE_FACEBOOK      2
#define SHAREMODE_TWITTER       3
#define SHAREMODE_VIDEO         4
#define SHAREMODE_PDF           5
#define SHAREMODE_YOUTUBE       6
#define SHAREMODE_WEIBO         7

#define IME_OK                  0
#define IME_CANCEL              1
#define IME_FAIL                2

#define COLORFROMRGBFLOAT(r,g,b)    COLORFROMRGB((int)((r)*255), (int)((g)*255), (int)((b)*255))
#define COLORFROMRGB(r,g,b)         (0xff000000U | ((r)<<16) | ((g)<<8) | (b))
#define REDFROMCOLOR(c)             (((((unsigned int)c)&0xff0000)>>16)/255.0f)
#define GREENFROMCOLOR(c)           (((((unsigned int)c)&0x00ff00)>>8)/255.0f)
#define BLUEFROMCOLOR(c)            ((((unsigned int)c)&0x0000ff)/255.0f)

#define MENU_BG_COLOR               [UIColor colorWithRed:0.4 green:0.5 blue:0.7 alpha:1]
#define MENU_BG_COLOR_T             [UIColor colorWithRed:0.4 green:0.5 blue:0.7 alpha:1]
#define MENU_LIGHT_COLOR            [UIColor colorWithRed:0.85 green:0.9 blue:1 alpha:1]
#define MENU_DARK_COLOR             [UIColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:1]

//#define SUPPORT_PINNING

#define ID_NONE                      0
#define ID_ANGLEMODE                 1
#define ID_INTERVALSTART             2
#define ID_INTERVALCOUNT             3
#define ID_DETAIL                    4
#define ID_SPIKINESS                 5
#define ID_TRUNKWIDTH                6
#define ID_RANDOMWIGGLE              7
#define ID_RANDOMANGLE               8
#define ID_RANDOMLENGTH              9
#define ID_TRUNKTAPER                10
#define ID_APEXTYPE                  11
#define ID_RANDOMINTERVAL            12
#define ID_RANDOMSEED                13
#define ID_ROOTCOLOR                 14
#define ID_LEAFCOLOR                 15
#define ID_BACKGROUNDCOLOR           16
#define ID_COLORSIZE                 17
#define ID_COLORTRANSITION           18
#define ID_BRANCHCOUNT               19
#define ID_GEONODES                  20
#define ID_ANIMWINDRATE              21
#define ID_ANIMWINDDEPTH             22
#define ID_ANIMSPREAD_D              23
#define ID_ANIMSPREAD_R              24
#define ID_SPREAD                    25
#define ID_ANIMBEND_D                26
#define ID_ANIMBEND_R                27
#define ID_BEND                      28
#define ID_ANIMSPIN_D                29
#define ID_ANIMSPIN_R                30
#define ID_SPIN                      31
#define ID_ANIMTWIST_D               32
#define ID_ANIMTWIST_R               33
#define ID_TWIST                     34
#define ID_ANIMLENGTHRATIO_D         35
#define ID_ANIMLENGTHRATIO_R         36
#define ID_LENGTHRATIO               37
#define ID_ANIMGEODELAY_D            38
#define ID_ANIMGEODELAY_R            39
#define ID_GEODELAY                  40
#define ID_ANIMGEORATIO_D            41
#define ID_ANIMGEORATIO_R            42
#define ID_GEORATIO                  43
#define ID_ANIMASPECT_D              44
#define ID_ANIMASPECT_R              45
#define ID_ASPECT                    46
#define ID_ANIMBALANCE_D             47
#define ID_ANIMBALANCE_R             48
#define ID_BALANCE                   49
#define ID_ANIMLENGTHBALANCE_D       50
#define ID_ANIMLENGTHBALANCE_R       51
#define ID_LENGTHBALANCE             52
#define ID_TREETYPE                  53
#define ID_ANIMENABLE                54

#define STRING_TREETYPE                  @"TreeType"
#define STRING_ANGLEMODE                 @"AngleMode"
#define STRING_SPREAD                    @"Spread"
#define STRING_BALANCE                   @"Balance"
#define STRING_BEND                      @"Bend"
#define STRING_INTERVALSTART             @"IntervalStart"
#define STRING_INTERVALCOUNT             @"IntervalCount"
#define STRING_DETAIL                    @"Detail"
#define STRING_LENGTHRATIO               @"LengthRatio"
#define STRING_LENGTHBALANCE             @"LengthBalance"
#define STRING_ASPECT                    @"Aspect"
#define STRING_SPIKINESS                 @"Spikiness"
#define STRING_TRUNKWIDTH                @"TrunkWidth"
#define STRING_RANDOMWIGGLE              @"RandomWiggle"
#define STRING_RANDOMANGLE               @"RandomAngle"
#define STRING_RANDOMLENGTH              @"RandomLength"
#define STRING_TRUNKTAPER                @"TrunkTaper"
#define STRING_APEXTYPE                  @"ApexType"
#define STRING_RANDOMINTERVAL            @"RandomInterval"
#define STRING_RANDOMSEED                @"RandomSeed"
#define STRING_ROOTCOLOR                 @"RootColor"
#define STRING_LEAFCOLOR                 @"LeafColor"
#define STRING_BACKGROUNDCOLOR           @"BackgroundColor"
#define STRING_COLORSIZE                 @"ColorSize"
#define STRING_COLORTRANSITION           @"ColorTransition"
#define STRING_BRANCHCOUNT               @"BranchCount"
#define STRING_GEONODES                  @"GeoNodes"
#define STRING_GEODELAY                  @"GeoDelay"
#define STRING_GEORATIO                  @"GeoRatio"
#define STRING_SPIN                      @"Spin"
#define STRING_TWIST                     @"Twist"
#define STRING_ANIMWINDRATE              @"AnimWindRate"
#define STRING_ANIMWINDDEPTH             @"AnimWindDepth"
#define STRING_ANIMSPREAD_D              @"AnimSpreadD"
#define STRING_ANIMSPREAD_R              @"AnimSpreadR"
#define STRING_ANIMBEND_D                @"AnimBendD"
#define STRING_ANIMBEND_R                @"AnimBendR"
#define STRING_ANIMSPIN_D                @"AnimSpinD"
#define STRING_ANIMSPIN_R                @"AnimSpinR"
#define STRING_ANIMTWIST_D               @"AnimTwistD"
#define STRING_ANIMTWIST_R               @"AnimTwistR"
#define STRING_ANIMLENGTHRATIO_D         @"AnimLengthRatioD"
#define STRING_ANIMLENGTHRATIO_R         @"AnimLengthRatioR"
#define STRING_ANIMGEODELAY_D            @"AnimGeoDelayD"
#define STRING_ANIMGEODELAY_R            @"AnimGeoDelayR"
#define STRING_ANIMGEORATIO_D            @"AnimGeoRatioD"
#define STRING_ANIMGEORATIO_R            @"AnimGeoRatioR"
#define STRING_ANIMASPECT_D              @"AnimAspectD"
#define STRING_ANIMASPECT_R              @"AnimAspectR"
#define STRING_ANIMBALANCE_D             @"AnimBalanceD"
#define STRING_ANIMBALANCE_R             @"AnimBalanceR"
#define STRING_ANIMLENGTHBALANCE_D       @"AnimLengthBalanceD"
#define STRING_ANIMLENGTHBALANCE_R       @"AnimLengthBalanceR"

//#define DEBUG_LOGGING

#ifdef DEBUG_LOGGING

#define DEBUG_PRINTF(a, ...) printf(a, ## __VA_ARGS__)
#define DEBUG_LOG(f, ...) NSLog(f, ## __VA_ARGS__)

#else

#define DEBUG_PRINTF(a, ...)
#define DEBUG_LOG(f, ...)

#endif

struct TreeFrame
{
    float x, y;
    float scale;
    float angle;
};

#endif
