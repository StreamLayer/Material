/*
 * Copyright (C) 2015 - 2018, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

extension UIViewController {
  /**
   A convenience property that provides access to the StatusBarController.
   This is the recommended method of accessing the StatusBarController
   through child UIViewControllers.
   */
  public var statusBarController: StatusBarController? {
    return traverseViewControllerHierarchyForClassType()
  }
}

open class StatusBarController: TransitionController {
  /**
   A Display value to indicate whether or not to
   display the rootViewController to the full view
   bounds, or up to the toolbar height.
   */
  open var displayStyle = DisplayStyle.full {
    didSet {
      layoutSubviews()
    }
  }

  #if os(iOS)
  /// Device status bar style.
  open var statusBarStyle: UIStatusBarStyle {
    get {
      return Application.statusBarStyle
    }
    set(value) {
      Application.statusBarStyle = value
    }
  }
  #endif

  #if os(iOS)
  /// Device visibility state.
  open var isStatusBarHidden: Bool {
    get {
      return Application.isStatusBarHidden
    }
    set(value) {
      Application.isStatusBarHidden = value
      statusBar.isHidden = isStatusBarHidden
    }
  }
  #endif

  /// An adjustment based on the rules for displaying the statusBar.
  open var statusBarOffsetAdjustment: CGFloat {
    #if os(iOS)
    return Application.shouldStatusBarBeHidden || statusBar.isHidden ? 0 : statusBar.bounds.height
    #else
    return 0
    #endif
  }

  /// A boolean that indicates to hide the statusBar on rotation.
  open var shouldHideStatusBarOnRotation = false

  /// A reference to the statusBar.
  public let statusBar = UIView()

  open override func layoutSubviews() {
    super.layoutSubviews()

    if shouldHideStatusBarOnRotation {
      #if os(iOS)
      statusBar.isHidden = Application.shouldStatusBarBeHidden
      #else
      statusBar.isHidden = true
      #endif
    }

    statusBar.frame.size.width = view.bounds.width

    if #available(iOS 11, *) {
      let v = topLayoutGuide.length
      statusBar.frame.size.height = 0 < v ? v : 20
    } else {
      statusBar.frame.size.height = 20
    }

    switch displayStyle {
    case .partial:
      let h = statusBar.bounds.height
      container.frame.origin.y = h
      container.frame.size.height = view.bounds.height - h

    case .full:
      container.frame = view.bounds
    }

    rootViewController.view.frame = container.bounds

    #if os(iOS)
    container.layer.zPosition = statusBar.layer.zPosition + (Application.shouldStatusBarBeHidden ? 1 : -1)
    #else
    container.layer.zPosition = statusBar.layer.zPosition + 1
    #endif
  }

  open override func prepare() {
    super.prepare()
    prepareStatusBar()
  }

  open override func apply(theme: Theme) {
    super.apply(theme: theme)

    statusBar.backgroundColor = theme.primary.darker
  }
}

fileprivate extension StatusBarController {
  /// Prepares the statusBar.
  func prepareStatusBar() {
    if nil == statusBar.backgroundColor {
      statusBar.backgroundColor = .white
    }

    view.addSubview(statusBar)
  }
}
