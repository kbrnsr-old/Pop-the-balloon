//
//  Game.m
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import "Game.h" 

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if (self = [super initWithWidth:width height:height])
    {
        // this is where the code of your game will start. 
        // in this sample, we add just a simple quad to see if it works.
        
        /*SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
        quad.color = 0xff0000;
        quad.x = 50;
        quad.y = 50;
        [self addChild:quad];
        */
		SPImage *backgroundImage = [SPImage imageWithContentsOfFile:@"tutorialbackground.png"];
		[self addChild:backgroundImage];
		
		score = 0;
		level = 1;
		
		scoreTextField = [SPTextField textFieldWithText:[NSString stringWithFormat:@"Score: %d", score]];
		levelTextField = [SPTextField textFieldWithText:[NSString stringWithFormat:@"Score: %d", level]];
		
		scoreTextField.fontName=@"Marker Felt";
		scoreTextField.x = 160;
		scoreTextField.y = 7;
		scoreTextField.vAlign = SPVAlignTop;
		scoreTextField.hAlign = SPHAlignRight;
		scoreTextField.fontSize = 20;
		
		[self addChild: scoreTextField];
		
		levelTextField.fontName=@"Marker Felt";
		levelTextField.x = 0;
		levelTextField.y = 7;
		levelTextField.vAlign = SPVAlignTop;
		levelTextField.fontSize = 20;
		
		[self addChild: levelTextField];
		
		SPSound *music = [SPSound soundWithContentsOfFile:@"music.caf"];
		
		SPSoundChannel *channel = [[music createChannel] retain];
		channel.loop = YES;
		channel.volume = 0.25;
		[channel play];
		
		
		
		
		balloonTextures = [NSMutableArray array];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"bluetutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"greentutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"indigotutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"orangetutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"redtutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"violettutorial.png"]];
		[balloonTextures addObject:[SPTexture textureWithContentsOfFile:@"yellowtutorial.png"]];
		[balloonTextures retain];
		
		playFieldSprite = [SPSprite sprite];
		[self addChild:playFieldSprite];
		[self addBalloon];
		


        // Per default, this project compiles as an iPhone application. To change that, enter the 
        // project info screen, and in the "Build"-tab, find the setting "Targeted device family".
        //
        // Now Choose:  
        //   * iPhone      -> iPhone only App
        //   * iPad        -> iPad only App
        //   * iPhone/iPad -> Universal App  
        // 
        // If you want to support the iPad, you have to change the "iOS deployment target" setting
        // to "iOS 3.2" (or "iOS 4.2", if it is available.)
    }
    return self;
}

-(void)addBalloon {
	
	SPImage *image = [SPImage imageWithTexture:[balloonTextures objectAtIndex:arc4random() % balloonTextures.count]];
	
	image.x = (arc4random() % (int)(self.width-image.width));
	image.y = self.height;
	
	[playFieldSprite addChild:image];
	
	SPTween *tween = [SPTween tweenWithTarget:image 
										 time:(double)((arc4random() % 5) + 2) 
								   transition:SP_TRANSITION_LINEAR];
	
	[tween animateProperty:@"x" targetValue:arc4random() % (int)(self.width-image.width)];
	[tween animateProperty:@"y" targetValue:-image.height];
	
	[self.juggler addObject:tween];
	
	[image addEventListener:@selector(onTouchBalloon:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	
	[tween addEventListener:@selector(movementThroughTopOfScreen:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
}

-(void)onTouchBalloon:(SPTouchEvent*)event {
	SPDisplayObject* currentBalloon = (SPDisplayObject*)[event target];
	[currentBalloon removeEventListener:@selector(onTouchBalloon:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

	score += 10;
	scoreTextField.text = [NSString stringWithFormat:@"Score %d", score];
	
	[[SPSound soundWithContentsOfFile:@"balloonpop.caf"] play];
	
	[self.juggler removeTweensWithTarget:currentBalloon];
	SPTween *tween = [SPTween tweenWithTarget:currentBalloon time:0.35 transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"scaleX" targetValue:0.75];
	[tween animateProperty:@"scaleY" targetValue:1.25];
	[self.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:currentBalloon time:(self.height-currentBalloon.y)/self.height transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"y" targetValue:self.height+currentBalloon.height];
	[self.juggler addObject:tween];
	[tween addEventListener:@selector(balloonPopped:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	
}

-(void)drawBalloons{
	for(int i = 0; i < level; i++) {
		[self addBalloon];
	}
}

-(void)movementThroughTopOfScreen:(SPEvent*) event {
	[self.juggler removeAllObjects];
	if (resetButtonVisible == NO) {
		resetButtonVisible == YES;
	}
	SPImage *backgroundImage = [SPImage imageWithContentsOfFile:@"screenoverlay.png"];
	[playFieldSprite addChild:backgroundImage];
	SPButton *resetButton = [SPButton buttonWithUpState:[SPTexture textureWithContentsOfFile:@"reset_button.png"]];
	resetButton.x = self.width/2-resetButton.width/2;
	resetButton.y = self.height/2-resetButton.height/2;
	resetButton.fontName=@"Marker Felt";
	resetButton.fontSize = 20;
	resetButton.text = @"Reset Game";
	
	[resetButton addEventListener:@selector(onResetButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	
	[playFieldSprite addChild: resetButton];
}

-(void)balloonPopped: (SPEvent*)event {
	SPTween *animation = (SPTween*)[event target];
	SPDisplayObject *currentBalloon = (SPDisplayObject*)[animation target];
	
	[playFieldSprite removeChild:currentBalloon];
	
	if(playFieldSprite.numChildren == 0) {
		
		level++;
		levelTextField.text = [NSString stringWithFormat:@"Level: %d", level];
		[self drawBalloons];
	}
}

-(void)onResetButtonTriggered:(SPEvent*) event {
	[playFieldSprite removeAllChildren];
	resetButtonVisible = NO;
	
	level = 1;
	score = 0;
	
	levelTextField.text = [NSString stringWithFormat:@"Level: %d", level];
	scoreTextField.text = [NSString stringWithFormat:@"Score: %d", score];
	
	[self addBalloon];
	
}


@end
