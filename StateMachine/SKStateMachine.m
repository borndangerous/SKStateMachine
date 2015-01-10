//
//  SKStateMachine.m
//  StateMachine
//
//  Created by Soroush Khanlou on 1/10/15.
//  Copyright (c) 2015 Soroush Khanlou. All rights reserved.
//

#import "SKStateMachine.h"

@implementation SKInvalidStateTransitionException

@end

@interface SKStateMachine ()

@property (nonatomic) NSString *currentState;
@property (nonatomic) SKSelectorConstructor *selectorConstructor;


@end

@implementation SKStateMachine

- (instancetype)initWithInitialState:(NSString *)initialState delegate:(id)delegate {
    self = [super init];
    if (!self) return nil;
    
    _currentState = initialState;
    _delegate = delegate;
    _selectorConstructor = [SKSelectorConstructor new];
    
    return self;
}

- (void)transitionToState:(NSString *)stateName {
    if (stateName) {
        SEL transitionSelector = [self selectorForTransitionToState:stateName];
        if ([self.delegate respondsToSelector:transitionSelector]) {
            self.currentState = stateName;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:transitionSelector];
#pragma clang diagnostic pop
            return;
        }
    }
    [SKInvalidStateTransitionException raise:@"Invalid State Transition!" format:@"The delegate does not respond to transitions of the type thingy."];
}

- (BOOL)canTransitionToState:(NSString *)stateName {
    return [self selectorForTransitionToState:stateName] != NULL;
}

- (SEL)selectorForTransitionToState:(NSString *)stateName {
    return [[[SKSelectorConstructor new] initWithComponents:@[@"transitionFrom", self.currentState, @"to", stateName]] selector];
}

@end



@interface SKSelectorConstructor ()

@property (nonatomic, strong) NSMutableArray *selectorComponents;


@end

@implementation SKSelectorConstructor

- (instancetype)initWithComponents:(NSArray *)components {
    self = [super init];
    if (!self) return nil;
    
    _components = components;
    
    return self;
}

- (SEL)selector {
    for (NSInteger i = 0; i < self.selectorComponents.count; i++) {
        [self formatSelectorComponentAtIndex:i];
    }
    
    NSString *selectorName = [self.selectorComponents componentsJoinedByString:@":"];
    
    return NSSelectorFromString(selectorName);
}

- (NSMutableArray *)selectorComponents {
    if (!_selectorComponents) {
        self.selectorComponents = [[[self joinedComponents] componentsSeparatedByString:@":"] mutableCopy];
    }
    return _selectorComponents;
}

- (void)formatSelectorComponentAtIndex:(NSInteger)index {
    NSString *component = self.selectorComponents[index];
    [self.selectorComponents replaceObjectAtIndex:index withObject:[self llamaCasedString:component]];
}

- (NSString *)joinedComponents {
    return [self.components componentsJoinedByString:@"-"];
}

- (NSString*)llamaCasedString:(NSString*)string {
    NSMutableArray *components = [[self componentsFromString:string] mutableCopy];
    
    for (NSInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if (i != 0) {
            [components replaceObjectAtIndex:i withObject:[component capitalizedString]];
        }
    }
    
    return [components componentsJoinedByString:@""];
}


- (NSArray *)componentsFromString:(NSString*)string {
    if (string.length == 0) return @[];
    
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -_"];
    NSArray *components = [string componentsSeparatedByCharactersInSet:separatorSet];
    
    NSMutableArray *allComponents = [NSMutableArray array];
    for (NSString *component in components) {
        [allComponents addObjectsFromArray:[self componentsSplitOnUppercase:component]];
    }
    
    for (NSString *component in allComponents.reverseObjectEnumerator) {
        if (component.length == 0) {
            [allComponents removeObject:component];
        }
    }
    return allComponents;
}

- (NSArray *)componentsSplitOnUppercase:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    
    NSArray *lowercaseComponents = [string componentsSeparatedByCharactersInSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    
    NSMutableArray *allComponents = [NSMutableArray array];
    for (NSString *incompleteComponent in lowercaseComponents) {
        if (incompleteComponent.length == 0) continue;
        
        NSRange rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        
        if (rangeOfIncompleteComponent.location > 1) {
            NSRange rangeOfUppercaseComponent = NSMakeRange(0, rangeOfIncompleteComponent.location-1);
            NSString *uppercaseComponent = [mutableString substringWithRange:rangeOfUppercaseComponent];
            
            [mutableString deleteCharactersInRange:rangeOfUppercaseComponent];
            
            [allComponents addObject:[uppercaseComponent lowercaseString]];
            rangeOfIncompleteComponent = [mutableString rangeOfString:incompleteComponent];
        }
        NSRange rangeOfFullComponent = NSMakeRange(0, rangeOfIncompleteComponent.length + rangeOfIncompleteComponent.location);
        NSString *fullComponent = [mutableString substringWithRange:rangeOfFullComponent];
        
        [mutableString deleteCharactersInRange:rangeOfFullComponent];
        
        [allComponents addObject:[fullComponent lowercaseString]];
    }
    
    if (mutableString.length != 0) {
        [allComponents addObject:[mutableString lowercaseString]];
    }
    
    return allComponents;
}


@end
