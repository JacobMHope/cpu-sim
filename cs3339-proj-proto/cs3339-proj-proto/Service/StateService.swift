//
//  StateService.swift
//  cs3339-proj-proto
//
//  Created by Connor Reid on 4/4/19.
//  Copyright © 2019 Connor Reid. All rights reserved.
//

import UIKit
import PromiseKit
import PMKUIKit

private enum StartState {
    case startPoint1Started
    case noneStarted
}

private enum EndState {
    case endPoint1Reached
    case endPoint2Reached
    case noneReached
}

class StateService: State {
    private var startState: StartState = StartState.noneStarted
    private var endState: EndState = EndState.noneReached

    private var firstPoint = CGPoint.zero
    private var lastPoint = CGPoint.zero

    func resetState() {
        startState = StartState.noneStarted
        endState = EndState.noneReached
    }

    private func onCorrect(
            _ touchPoint: TouchPointView,
            lines: [LineView]) {

        // Set touch point correct...
        touchPoint.setCorrect()

        // ...then stop pulsating after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            touchPoint.stop()

            switch touchPoint.name {
            case "endTouchPoint2":

                // Animate each line in sequence
                var animate = Guarantee()
                for line in lines {
                    if (line.endPointName == "endTouchPoint2") {
                        animate = animate.then {
                            UIView.animate(.promise, duration: 0.75) {
                                line.alpha = 1.0
                            }.asVoid()
                        }
                    }
                }

                break;
            default:
                break;
            }
        }
    }

    private func onIncorrect(_ touchPoint: TouchPointView) {
        // Set touch point incorrect...
        touchPoint.setIncorrect()

        // ...then reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            touchPoint.reset()
        }
    }

    func handleTouchesBegan(
            _ touches: Set<UITouch>,
            with event: UIEvent?,
            touchPoints: [TouchPointView],
            view: UIView) {

        if let touch = touches.first {
            lastPoint = touch.location(in: view)
            firstPoint = lastPoint

            touchPoints.forEach { touchPoint in
                if (touchPoint == touchPoint.hitTest(touch, event: event)) {
                    if (touchPoint.name == "startTouchPoint") {
                        self.startState = StartState.startPoint1Started
                    }
                }
            }
        }
    }

    func handleTouchesMoved(
            _ touches: Set<UITouch>,
            with event: UIEvent?,
            imageView: UIImageView,
            view: UIView,
            withDrawing drawingService: Drawing,
            touchPoints: [TouchPointView],
            lines: [LineView]) {

        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawingService.drawLineFrom(
                    fromPoint: self.lastPoint,
                    toPoint: currentPoint,
                    imageView: imageView,
                    view: view)

            lastPoint = currentPoint

            touchPoints.forEach { touchPoint in
                if (touchPoint == touchPoint.hitTest(touch, event: event)) {
                    switch touchPoint.name {
                    case "endTouchPoint1":
                        if (self.startState == StartState.startPoint1Started) {
                            self.onIncorrect(touchPoint)
                            drawingService.ignoreTouchInput()
                            drawingService.clearDrawing(imageView: imageView)
                        }
                        break;
                    case "endTouchPoint2":
                        if (self.startState == StartState.startPoint1Started) {
                            self.onCorrect(touchPoint, lines: lines)
                            drawingService.ignoreTouchInput()
                            drawingService.clearDrawing(imageView: imageView)
                        }
                        break;

                    default:
                        // Do nothing
                        break;
                    }
                }
            }
        }
    }

    func handleTouchesEnded() {
        self.resetState()
    }

    func handleTouchesCancelled(withDrawing drawingService: Drawing) {
        drawingService.resumeTouchInput()
        self.resetState()
    }
}