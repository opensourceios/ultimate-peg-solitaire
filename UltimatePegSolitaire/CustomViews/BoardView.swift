//
//  BoardView.swift
//  UltimatePegSolitaire
//
//  Created by Maksim Khrapov on 11/3/19.
//  Copyright © 2019 Maksim Khrapov. All rights reserved.
//

// https://www.ultimatepegsolitaire.com/
// https://github.com/mkhrapov/ultimate-peg-solitaire
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import UIKit

final class BoardView: UIView {
    var gameState: GameState?
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        guard let gameState = gameState else {
            return
        }
        
        let draw = Draw(context, bounds, gameState)
        draw.draw()
    }
    
    
    func decipher(_ px: CGFloat, _ py: CGFloat) -> (Int, Int)? {
        guard let gameState = gameState else {
            return nil
        }
        
        let calc = Calc(bounds, gameState)
        return calc.decipher(px, py)
    }
    
    
    final class Calc {
        let rect: CGRect
        let gameState: GameState
        var offsetX: CGFloat = 1.0
        var offsetY: CGFloat = 1.0
        var cellSize: CGFloat = 0.0
        let X: Int
        let Y: Int
        
        
        init(_ r: CGRect, _ gs: GameState) {
            rect = r
            gameState = gs
            X = gameState.board.X
            Y = gameState.board.Y
        }
        
        
        func calcParams() {
            let width = rect.width - CGFloat(2.0)
            let height = rect.height - CGFloat(2.0)
            
            if X > Y {
                cellSize = width / CGFloat(X)
                offsetY = (height - cellSize*CGFloat(Y))/2.0 + CGFloat(1.0)
            }
            else if Y > X {
                cellSize = height / CGFloat(Y)
                offsetX = (width - cellSize*CGFloat(X))/2.0 + CGFloat(1.0)
            }
            else {
                cellSize = width / CGFloat(X)
            }
        }
        
        
        func decipher(_ px: CGFloat, _ py: CGFloat) -> (Int, Int)? {
            calcParams()
            
            let x = Int(floor((px - offsetX)/cellSize))
            let y = Int(floor((py - offsetY)/cellSize))
            
            if x < 0 || y < 0 || x >= X || y >= Y {
                return nil
            }
            
            return (x, y)
        }
    }
    
    
    final class Draw {
        let context: CGContext
        let rect: CGRect
        let gameState: GameState
        let myColors: MyColors
        var offsetX: CGFloat = 1.0
        var offsetY: CGFloat = 1.0
        var cellSize: CGFloat = 0.0
        let X: Int
        let Y: Int
        
        
        init(_ c: CGContext, _ r: CGRect, _ gs: GameState) {
            context = c
            rect = r
            gameState = gs
            myColors = MyColors()
            X = gameState.board.X
            Y = gameState.board.Y
        }
        
        
        func draw() {
            calcParams()
            fillBackground()
            drawCells()
        }
        
        
        func calcParams() {
            let width = rect.width - CGFloat(2.0)
            let height = rect.height - CGFloat(2.0)
            
            if X > Y {
                cellSize = width / CGFloat(X)
                offsetY = (height - cellSize*CGFloat(Y))/2.0 + CGFloat(1.0)
            }
            else if Y > X {
                cellSize = height / CGFloat(Y)
                offsetX = (width - cellSize*CGFloat(X))/2.0 + CGFloat(1.0)
            }
            else {
                cellSize = width / CGFloat(X)
            }
        }
        
        
        func fillBackground() {
            context.setFillColor(myColors.background)
            context.fill(rect)
        }
        
        
        func drawCells() {
            for x in 0..<X {
                for y in 0..<Y {
                    let i = y*X + x
                    if gameState.board.isAllowed(x, y) {
                        let cell = makeCell(x, y)
                        drawBorder(cell)
                        if gameState.last.isOccupied(x, y) {
                            if gameState.last.selected == i {
                                drawPeg(cell: cell, color: myColors.selected)
                            }
                            else {
                                drawPeg(cell: cell, color: myColors.normal)
                            }
                        }
                        else if gameState.last.isValidMoveTarget(x, y) {
                            drawPeg(cell: cell, color: myColors.allowed)
                        }
                    }
                }
            }
        }
        
        
        func makeCell(_ x: Int, _ y: Int) -> CGRect {
            let dx = offsetX + cellSize*CGFloat(x)
            let dy = offsetY + cellSize*CGFloat(y)
            return CGRect(x: dx, y: dy, width: cellSize, height: cellSize)
        }
        
        
        func drawBorder(_ cell: CGRect) {
            context.setStrokeColor(myColors.border)
            context.setLineWidth(1)
            context.beginPath()
            context.addRect(cell)
            context.strokePath()
        }
        
        
        func drawPeg(cell: CGRect, color: CGColor) {
            let smallCell = cell.insetBy(dx: 3.0, dy: 3.0)
            
            context.setFillColor(color)
            context.fillEllipse(in: smallCell)
        }
    }
}
