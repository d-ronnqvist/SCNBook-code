//
//  ChessView.m
//  Chapter 05 - Chess
//
//  Created by David Rönnqvist on 2014-04-05.
//  Copyright (c) 2014 David Rönnqvist.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "ChessView.h"

// Used to identify the different types of pieces in the scene
NSString * const PawnType   = @"Pawn";
NSString * const RookType   = @"Rook";
NSString * const KnightType = @"Knight";
NSString * const BishopType = @"Bishop";
NSString * const QueenType  = @"Queen";
NSString * const KingType   = @"King";


// A square on the chess board is usually specific with both a
// letter and a number. For this I'm using a custom struct called
// 'ChessSquare'. The letters start at 'A' and the numbers at '1'.
struct ChessSquare {
    char column;
    char row;
};
typedef struct ChessSquare ChessSquare;

ChessSquare ChessSquareMake(char column, char row)
{
    ChessSquare square;
    square.column = column;
    square.row    = row;
    return square;
}



@interface ChessView ()
// The source that the pieces are read from
@property (nonatomic, strong) SCNScene *pieces;

// The node that holds all the pieces (used when hit testing)
@property (nonatomic, strong) SCNNode *piecesNode;

// The two colors
@property (nonatomic, strong) NSColor *lightColor;
@property (nonatomic, strong) NSColor *darkColor;

@end


@implementation ChessView

- (void)awakeFromNib
{
    // Base scene setup
    // ---------------
	SCNScene *scene = [SCNScene scene];
	self.scene = scene;
    self.backgroundColor = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
	
	
	// Add a camera ...
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(3.5, 4.7, 7);
	[scene.rootNode addChildNode:cameraNode];
	
    // ...that looks at the center of the
	SCNNode *cameraTarget = [SCNNode node];
	cameraTarget.position = SCNVector3Make(0, -2, 0);
	SCNLookAtConstraint *lookAtCenter =
      [SCNLookAtConstraint lookAtConstraintWithTarget:cameraTarget];
	lookAtCenter.gimbalLockEnabled = YES;
	cameraNode.constraints = @[lookAtCenter];

    
    // Add 4 omni lights above the corners of the chess board
	SCNLight *light = [SCNLight light];
	light.type = SCNLightTypeOmni;
	[light setAttribute:@5  forKey:SCNLightAttenuationStartKey];
	[light setAttribute:@25 forKey:SCNLightAttenuationEndKey];
	light.color = [NSColor whiteColor];
    
	SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    
    // The lights are positioned at a certain height and at
    // some offset from the center, along both X and Z.
    CGFloat height = 3;
	CGFloat offset = 5;

	// Make copies of the omni light and change the position.
	lightNode.position = SCNVector3Make(-offset, height, -offset);
	[scene.rootNode addChildNode:[lightNode copy]];
	lightNode.position = SCNVector3Make(-offset, height,  offset);
	[scene.rootNode addChildNode:[lightNode copy]];
	lightNode.position = SCNVector3Make( offset, height, -offset);
	[scene.rootNode addChildNode:[lightNode copy]];
	lightNode.position = SCNVector3Make( offset, height,  offset);
	[scene.rootNode addChildNode:[lightNode copy]];
	
    
    
    // Chess board + chess pieces
    // --------------------------
    
	[self addChessBoard];
    
    // Place a number of chess pieces in different locations.
    // This setups intends to look like a real game of chess.
    
    // White player
    [self addPieceOfType:RookType   isWhitePlayer:YES atSquare:ChessSquareMake('A', 4)];
	[self addPieceOfType:KnightType isWhitePlayer:YES atSquare:ChessSquareMake('A', 2)];
	[self addPieceOfType:BishopType isWhitePlayer:YES atSquare:ChessSquareMake('B', 4)];
	[self addPieceOfType:QueenType  isWhitePlayer:YES atSquare:ChessSquareMake('E', 1)];
	[self addPieceOfType:KingType   isWhitePlayer:YES atSquare:ChessSquareMake('A', 7)];
	[self addPieceOfType:KnightType isWhitePlayer:YES atSquare:ChessSquareMake('E', 2)];
	[self addPieceOfType:RookType   isWhitePlayer:YES atSquare:ChessSquareMake('A', 6)];
	
	[self addPieceOfType:PawnType   isWhitePlayer:YES atSquare:ChessSquareMake('D', 3)];
	[self addPieceOfType:PawnType   isWhitePlayer:YES atSquare:ChessSquareMake('F', 5)];
	[self addPieceOfType:PawnType   isWhitePlayer:YES atSquare:ChessSquareMake('C', 6)];
	[self addPieceOfType:PawnType   isWhitePlayer:YES atSquare:ChessSquareMake('B', 7)];
	
	// Black player
	[self addPieceOfType:RookType   isWhitePlayer:NO  atSquare:ChessSquareMake('H', 6)];
	[self addPieceOfType:KnightType isWhitePlayer:NO  atSquare:ChessSquareMake('E', 7)];
	[self addPieceOfType:BishopType isWhitePlayer:NO  atSquare:ChessSquareMake('H', 3)];
	[self addPieceOfType:KingType   isWhitePlayer:NO  atSquare:ChessSquareMake('H', 4)];
	[self addPieceOfType:QueenType  isWhitePlayer:NO  atSquare:ChessSquareMake('B', 2)];
	[self addPieceOfType:RookType   isWhitePlayer:NO  atSquare:ChessSquareMake('H', 8)];
	
	[self addPieceOfType:PawnType   isWhitePlayer:NO  atSquare:ChessSquareMake('G', 2)];
	[self addPieceOfType:PawnType   isWhitePlayer:NO  atSquare:ChessSquareMake('F', 3)];
	[self addPieceOfType:PawnType   isWhitePlayer:NO  atSquare:ChessSquareMake('E', 6)];
	[self addPieceOfType:PawnType   isWhitePlayer:NO  atSquare:ChessSquareMake('C', 7)];

}

SCNVector3 positionForRowColumn(NSInteger row, NSInteger column)
{
    return SCNVector3Make(3.5-column, 0.0, 3.5-row);
}

- (void)addChessBoard
{
    // Creates a chess board out of a collection of light and dark boxes
    
    // Create two boxes
	SCNBox* lightSquare = [SCNBox boxWithWidth:1
										height:0.2
										length:1
								 chamferRadius:0];
	SCNBox* darkSquare = [lightSquare copy];
    
    // Create (and assign) two materials
	SCNMaterial* lightMaterial = [SCNMaterial material];
	lightMaterial.diffuse.contents = self.lightColor;
    
	SCNMaterial* darkMaterial = [lightMaterial copy];
	darkMaterial.diffuse.contents = [NSColor colorWithCalibratedWhite:.15
																alpha:1.0];
	lightSquare.firstMaterial = lightMaterial;
	darkSquare.firstMaterial = darkMaterial;
    
    
    
    // Create a board node to hold all the nodes
	SCNNode* boardNode = [SCNNode node];
	boardNode.position = SCNVector3Make(0, -0.11, 0);
    
    // Loop over every square in the grid
	for (NSInteger row = 0; row < 8; row++) {
		for (NSInteger col = 0; col < 8; col++) {
            // Make node with a copy of the black or white square
			BOOL isBlack = (row + col) % 2 == 0;
			SCNGeometry* geometry = isBlack ? darkSquare : lightSquare;
			SCNNode* squareNode = [SCNNode nodeWithGeometry:[geometry copy]];
            
            // Position it and add it to the board
			squareNode.position = positionForRowColumn(row, col);
			[boardNode addChildNode:squareNode];
		}
	}
    
	[self.scene.rootNode addChildNode:[boardNode flattenedClone]];
}

- (void)addPieceOfType:(NSString *)type
         isWhitePlayer:(BOOL)isWhitePlayer
              atSquare:(ChessSquare)square
{
    // Translate the square into numbers
    const NSInteger firstLetter = (int)'A';
    const NSInteger firstNumber = 1;
    
    
    NSInteger row    = square.row    - firstNumber;
    NSInteger column = square.column - firstLetter;
    

    // Read the piece node from the source ...
	SCNNode *pieceNode = [self.pieces.rootNode childNodeWithName:type recursively:YES];
    // ... and make a copy so that it can be placed on the board
    pieceNode = [pieceNode copy];
	
    if (!isWhitePlayer) {
        // Black pieces needs to be copied so that they can use another material
        
        // copy the piece (the geometry)
        pieceNode.geometry = [pieceNode.geometry copy];
        
        // copy the material and change the diffuse property
        SCNMaterial *blackMaterial = [pieceNode.geometry.firstMaterial copy];
        blackMaterial.diffuse.contents = self.darkColor;

        // set the new material on the piece
        pieceNode.geometry.firstMaterial = blackMaterial;
    }
	
    // Rotate the piece so that they are alwyas facing their opponent
	pieceNode.rotation = SCNVector4Make(0, 1, 0,
										isWhitePlayer ? 1.5*M_PI : 0.5*M_PI);
	
	// position the piece
	pieceNode.position = positionForRowColumn(row, column);
    
    // I want 1 unit of distance to be one square so the pieces are
    // scaled down to 2/3 of their size, so that this can be true.
	pieceNode.scale = SCNVector3Make(.67, .67, .67);
	
	[self.piecesNode addChildNode:pieceNode];
}


- (void)mouseUp:(NSEvent *)theEvent
{
	[super mouseUp:theEvent];
	
    // Get the location of the click
	NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:eventLocation fromView:nil];
	
    // Only hit test the pieces
	NSDictionary *onlyPiecesOptions = @{SCNHitTestRootNodeKey: self.piecesNode};
	NSArray *hits = [self hitTest:point
						  options:onlyPiecesOptions];
	
	// Get the closest piece
	SCNHitTestResult *hit = hits.firstObject;
	SCNNode *pieceNode = hit.node;

    // Add an animaion if the node isn't already animating
	if (pieceNode.animationKeys.count == 0) {
		[hit.node addAnimation:[self jumpAnimation] forKey:@"Jump"];
	}

}


#pragma mark - Lazy initializers

- (SCNScene *)pieces
{
    if (!_pieces) {
        _pieces = [SCNScene sceneNamed:@"chess pieces"];
    }
    return _pieces;
}

- (SCNNode *)piecesNode
{
    if (!_piecesNode) {
        _piecesNode = [SCNNode node];
        [self.scene.rootNode addChildNode:_piecesNode];
    }
    return _piecesNode;
}

- (NSColor *)lightColor
{
    if (!_lightColor) {
        _lightColor = [NSColor colorWithCalibratedRed:0.9 green:0.85 blue:0.8 alpha:1.0];
    }
    return _lightColor;
}

- (NSColor *)darkColor
{
    if (!_darkColor) {
        _darkColor = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
    }
    return _darkColor;
}


#pragma mark - Animation

- (CAAnimation *)jumpAnimation
{
    // An animation of the position that looks like the node jumps up and bounces on the ground
	CAKeyframeAnimation *jump = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
	
	CAMediaTimingFunction *easeIn  = [CAMediaTimingFunction functionWithControlPoints:0.35 :0.0  :1.0  :1.0];
	CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithControlPoints:0.0  :1.0  :0.65 :1.0];
	
	jump.values   = @[@(0.000000), @(0.433333), @(0.000000), @(0.124444), @(0.000000), @(0.035111), @(0.000000)];
	jump.keyTimes = @[@(0.000000), @(0.255319), @(0.531915), @(0.680851), @(0.829788), @(0.914894), @(1.000000)];
	jump.timingFunctions = @[  easeOut,     easeIn,      easeOut,     easeIn,      easeOut,     easeIn   ];
	jump.duration = 0.783333;
	
	return jump;
}

@end
