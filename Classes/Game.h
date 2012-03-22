//
//  Game.h
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h" 

@interface Game : SPStage {
	int score;
	int level;
	SPTextField *scoreTextField;
	SPTextField *levelTextField;
	NSMutableArray *balloonTextures;
	SPSprite *playFieldSprite;
	BOOL resetButtonVisible;
}

-(void)addBalloon;
-(void)onTouchBalloon:(SPTouchEvent*)event;
-(void)drawBalloons;
-(void)movementThroughTopOfScreen:(SPEvent*) event;
-(void)balloonPopped:(SPEvent*) event;

@end
