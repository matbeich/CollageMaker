//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Firebase
import Foundation

class AppContext {
    let photoLibrary: PhotoLibraryType
    let collageRenderer: CollageRendererType
    let shareService: ShareServiceType
    let photoAuthService: PhotoAuthServiceType
    let cameraAuthService: CameraAuthServiceType
    let templateProvider: CollageTemplateProvider
    let remoteSettingsService: RemoteSettingsService

    init(photoLibrary: PhotoLibraryType = PhotoLibrary(),
         collageRenderer: CollageRendererType = CollageRenderer(),
         cameraAuthService: CameraAuthServiceType = CameraAuthService(),
         photoAuthService: PhotoAuthServiceType = PhotoAuthService(),
         remoteSettingsService: RemoteSettingsService = .shared,
         shareService: ShareServiceType? = nil) {
        self.photoLibrary = photoLibrary
        self.collageRenderer = collageRenderer
        self.photoAuthService = photoAuthService
        self.cameraAuthService = cameraAuthService
        self.remoteSettingsService = remoteSettingsService
        self.shareService = shareService ?? ShareService(photoLibrary: photoLibrary)
        self.templateProvider = CollageTemplateProvider(photoLibrary: photoLibrary)
    }
}
