//
//  ALUCoordinator.swift
//  CPUSim
//
//  Created by Jacob Morgan Hope on 3/31/19.
//  Copyright © 2019 Jacob M. Hope. All rights reserved.
//

import UIKit

protocol ALUCoordinatorDelegate: class {
    func aluCoordinatorDidRequestCancel(aluCoordinator: ALUCoordinator)
    func aluCoordinator(aluCoordinator: ALUCoordinator, payload: ALUCoordinatorPayload)
}

class ALUCoordinatorPayload {
    // Data passed through the view controllers
}

class ALUCoordinator: RootViewCoordinator {

    // MARK: Properties

    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return self.navigationController
    }
    weak var delegate: ALUCoordinatorDelegate?
    var orderPayload: ALUCoordinatorPayload?
    lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        return navigationController
    }()

    // MARK: Properties - Drawing State Services

    let drawingService: Drawing

    // MARK: Properties - Instruction State Services

    let fetchStateService: State
    let decodeStateService: State
    let executeStateService: State
    let memoryAccessStateService: State
    let writeBackStateService: State

    // MARK: Properties - VCs

    private var dvc: DecodeViewController? = nil
    private var evc: ExecuteViewController? = nil
    private var mavc: MemoryAccessViewController? = nil
    private var wbvc: WriteBackViewController? = nil

    // MARK: Init

    init(drawingService: Drawing,
         fetchStateService: State,
         decodeStateService: State,
         executeStateService: State,
         memoryAccessStateService: State,
         writeBackStateService: State) {
        self.drawingService = drawingService
        self.fetchStateService = fetchStateService
        self.decodeStateService = decodeStateService
        self.executeStateService = executeStateService
        self.memoryAccessStateService = memoryAccessStateService
        self.writeBackStateService = writeBackStateService
    }

    // MARK: Functions

    func start() {
        self.showFetchViewController()
    }

    func showFetchViewController() {
        let fetchViewController = FetchViewController()
        fetchViewController.delegate = self
        self.navigationController.viewControllers = [fetchViewController]
    }

    func showDecodeViewController() {
        // Lazy init the DecodeViewController
        if (dvc == nil) {
            dvc = DecodeViewController()
            dvc?.delegate = self
        }
        
        // Safe bang due to lazy initialization above
        self.navigationController.pushViewController(dvc!, animated: true)
    }

    func showExecuteViewController() {
        // Lazy init the ExecuteViewController
        if (evc == nil) {
            evc = ExecuteViewController()
            evc?.delegate = self
        }
        
        // Safe bang due to lazy initialization above
        self.navigationController.pushViewController(evc!, animated: true)
    }

    func showMemoryAccessViewController() {
        // Lazy init the MemoryAccessViewController
        if (mavc == nil) {
            mavc = MemoryAccessViewController()
            mavc?.delegate = self
        }

        // Safe bang due to lazy initialization above
        self.navigationController.pushViewController(mavc!, animated: true)
    }

    func showWriteBackViewController() {
        // Lazy init the WriteBackViewController
        if (wbvc == nil) {
            wbvc = WriteBackViewController()
            wbvc?.delegate = self
        }

        // Safe bang due to lazy initialization above
        self.navigationController.pushViewController(wbvc!, animated: true)
    }
}
