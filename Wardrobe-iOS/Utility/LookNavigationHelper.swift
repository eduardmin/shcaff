//
//  LookNavigationHelper.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/16/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import Foundation
import UIKit

func addAlbumWithHelper(selectedLook: LookModelSuggestion, looks: [LookModelSuggestion], image: UIImage, viewController: UIViewController) {
    let lookDetailViewModel = LookDetailViewModel(selectedLookModel: selectedLook, looksModel: looks, image: image)
    lookDetailViewModel.updateCompletion = { type in
        switch type {
        case .start(showLoading: _):
            LoadingIndicator.show(on: viewController.view)
        case .fail(showPopup: _):
            AlertPresenter.presentRequestErrorAlert(on: viewController)
            LoadingIndicator.hide(from: viewController.view)
        case .success(response: _):
            LoadingIndicator.hide(from: viewController.view)
        }
    }
    let album = AlbumsViewController()
    album.type = .set
    album.modalPresentationStyle = .fullScreen
    album.albumCompletion = { album in
        lookDetailViewModel.saveLook(album)
    }
    viewController.present(album, animated: true, completion: nil)
}

func addCalendarWithHelper(selectedLook: LookModelSuggestion, looks: [LookModelSuggestion], image: UIImage, viewController: UIViewController) {
    let lookDetailViewModel = LookDetailViewModel(selectedLookModel: selectedLook, looksModel: looks, image: image)
    let calendarViewController: CalendarViewController = CalendarViewController.initFromStoryboard()
    calendarViewController.viewModel.setSetModel(lookDetailViewModel.getSetModel())
    calendarViewController.navigationType = .selectDate
    let calendarNavigationController = UINavigationController(rootViewController: calendarViewController)
    calendarNavigationController.modalPresentationStyle = .fullScreen
    calendarNavigationController.navigationBar.isHidden = true
    viewController.present(calendarNavigationController, animated: true, completion: nil)
}
