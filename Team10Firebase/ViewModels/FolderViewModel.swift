//
//  FolderViewModel.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

class FolderViewModel: ObservableObject {
  @Published var folder: Folder?
  
  
  init(folder: Folder) {
    self.folder = folder
  }
}
