//
//  SKStateMachine.h
//  StateMachine
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKInvalidStateTransitionException : NSException

@end

@interface SKStateMachine : NSObject

- (instancetype)initWithInitialState:(NSString *)initialState delegate:(id)delegate;

@property (nonatomic, weak, readonly) id delegate;

@property (nonatomic, readonly) NSString *currentState;

- (void)transitionToState:(NSString *)stateName;
- (BOOL)canTransitionToState:(NSString *)stateName;

@end
