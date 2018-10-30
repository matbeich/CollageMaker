//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation

class AppContext {
    let photoLibrary: PhotoLibraryType
    let collageRenderer: CollageRendererType
    let shareService: ShareServiceType
    let photoAuthService: PhotoAuthServiceType
    let cameraAuthService: CameraAuthServiceType
    let templateProvider: CollageTemplateProvider

    init(photoLibrary: PhotoLibraryType = PhotoLibrary(),
         collageRenderer: CollageRendererType = CollageRenderer(),
         cameraAuthService: CameraAuthServiceType = CameraAuthService(),
         photoAuthService: PhotoAuthServiceType = PhotoAuthService(),
         shareService: ShareServiceType? = nil) {
        self.photoLibrary = photoLibrary
        self.collageRenderer = collageRenderer
        self.photoAuthService = photoAuthService
        self.cameraAuthService = cameraAuthService
        self.shareService = shareService ?? ShareService(photoLibrary: photoLibrary)
        self.templateProvider = CollageTemplateProvider(photoLibrary: photoLibrary)
    }
}
