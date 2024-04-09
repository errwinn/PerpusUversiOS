//
//  PDFView.swift
//  PerpusUvers
//
//  Created by Erwin on 04/04/24.
//

import SwiftUI
import PDFKit

struct BookPdfView: View {
    var url: URL
    var body: some View {
        PDFKitRepresentedView(documentURL: url)
            .toolbar(.hidden, for: .tabBar)
            .screenshotProtected(isProtected: true)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let documentURL: URL
    init(documentURL: URL) {
        self.documentURL = documentURL
    }
    
    func makeUIView(context: Context) -> some UIView {
        let pdfView: PDFView = PDFView()
        pdfView.document = PDFDocument(url: documentURL)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
