//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Compu on 11/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Gameplay.h"

@implementation Gameplay{
    
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    
}


/*
 int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
        return retVal;
    }
}
*/
// is called when CCB file has completed loading
-(void)didLoadFromCCB{
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    // visualize physics bodies and joints
    _physicsNode.debugDraw = TRUE;
    
    // nothing shall collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    
}



// called on every touch in this scene
-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event  {
    
    
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)){
        
        // create a penguin from the ccb-file
        _currentPenguin = [CCBReader load:@"Penguin"];
        // initially position it on the scoop. 34,138 is the position in space of the _catapultArm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:penguinPosition];
        // transform the node position to the node space to which the penguin will be added
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        // add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        // we don't want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        // create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        
    }
    
}

-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    _mouseJointNode.position = touchLocation;
    
}

-(void)releaseCatapult{
    
    if (_mouseJoint != nil) {
        
        //releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        // releases the joint and lets the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        // after snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        
        // follow the flying penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
        
    }
    
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    // when touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];

}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    // when the touches are cancelled, meaning the user drags their finger off the screen or something else, release the catapult
    [self releaseCatapult];
    
}

// is called when CCB file has completed loading
/*- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
}
*/

// called on every touch in this scene
/*- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self launchPenguin];
}
*/
-(void)launchPenguin{
    
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* penguin = [CCBReader load:@"Penguin"];
    
    // position the Penguin.ccb at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    // manually create and apply a force to launch a penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    
}

-(void)Refly{
    
    // reload this level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
    
}

@end


