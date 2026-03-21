//
//  ShareHandlerIosViewController.swift
//  Pods
//
//  Created by Josh Juncker on 7/7/22.
//

import UIKit
import Social
import MobileCoreServices
import Photos
import Intents
import Contacts

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
open class ShareHandlerIosViewController: UIViewController {
    static var hostAppBundleIdentifier = ""
    static var appGroupId = ""
    let sharedKey = "ShareKey"
    var sharedText: [String] = []
    let imageContentType = UTType.image.identifier
    let movieContentType = UTType.movie.identifier
    let textContentType = UTType.text.identifier
    let urlContentType = UTType.url.identifier
    let fileURLType = UTType.fileURL.identifier
    let dataContentType = UTType.data.identifier
    var sharedAttachments: [SharedAttachment] = []
    private var fileNameCounter: [String: Int] = [:]
    lazy var userDefaults: UserDefaults = {
        return UserDefaults(suiteName: ShareHandlerIosViewController.appGroupId)!
    }()

    public func loadIds() {
            // loading Share extension App Id
            let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!;


            // convert ShareExtension id to host app id
            // By default it is remove last part of id after last point
            // For example: com.test.ShareExtension -> com.test
            let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".");
        ShareHandlerIosViewController.hostAppBundleIdentifier = String(shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!]);

            // loading custom AppGroupId from Build Settings or use group.<hostAppBundleIdentifier>
        ShareHandlerIosViewController.appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(ShareHandlerIosViewController.hostAppBundleIdentifier)";
        }

    public override func viewDidLoad() {
        super.viewDidLoad();

        // load group and app id from build info
                loadIds();
        Task {
            await handleInputItems()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    func handleInputItems() async {
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in (contents).enumerated() {
                    do {
                        if attachment.hasItemConformingToTypeIdentifier(imageContentType) {
                            try await handleImages(content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(movieContentType) {
                            try await handleVideos(content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(fileURLType){
                            try await handleFiles(content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                            try await handleUrl(content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                            try await handleText(content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(dataContentType) {
                            try await handleData(content: content, attachment: attachment, index: index)
                        } else {
                            print("Attachment not handled with registered type identifiers: \(attachment.registeredTypeIdentifiers)")
                        }
                    } catch {
                        self.dismissWithError()
                    }

                }
            }
            redirectToHostApp()
        }
    }

    public func getNewFileUrl(fileName: String) -> URL {
        let newFileUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: ShareHandlerIosViewController.appGroupId)!
            .appendingPathComponent(fileName)
        return newFileUrl
    }

    public func handleText (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: textContentType, options: nil)

        if let item = data as? String {
            sharedText.append(item)
        } else {
            if let d = data as? Data {
                do{
                    let contacts = try CNContactVCardSerialization.contacts(with: d)
                    for contact in contacts {
                        let data = try CNContactVCardSerialization.data(with: [contact])
                        let str = String(data: data, encoding: .utf8)!
                        sharedText.append(str)
                    }
                } catch {
                    dismissWithError()
                }
            } else {
                dismissWithError()
            }
        }
    }

    public func handleUrl (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: urlContentType, options: nil)

            if let item = data as? URL {
                sharedText.append(item.absoluteString)
            } else {
                dismissWithError()
            }

    }

    public func handleImages (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: imageContentType, options: nil)

        var fileName: String?
        var imageData: Data?
        var sourceUrl: URL?
        if let url = data as? URL {
            fileName = getFileName(from: url, type: .image)
            sourceUrl = url
        } else if let iData = data as? Data {
            fileName = UUID().uuidString + ".png"
            imageData = iData
        } else if let image = data as? UIImage {
            fileName = UUID().uuidString + ".png"
            imageData = image.pngData()
        }

        if let _fileName = fileName {
            let newFileUrl = getNewFileUrl(fileName: _fileName)
            do {
                if FileManager.default.fileExists(atPath: newFileUrl.path) {
                    try FileManager.default.removeItem(at: newFileUrl)
                }
            } catch {
                print("Error removing item")
            }


            var copied: Bool = false
            if let _data = imageData {
                copied = FileManager.default.createFile(atPath: newFileUrl.path, contents: _data)
            } else if let _sourceUrl = sourceUrl {
                copied = copyFile(at: _sourceUrl, to: newFileUrl)
            }

            if (copied) {
                sharedAttachments.append(SharedAttachment.init(path:  newFileUrl.absoluteString, type: .image))
            } else {
                dismissWithError()
                return
            }

        } else {
            dismissWithError()
            return
        }

    }

    public func handleVideos (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: movieContentType, options: nil)


        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from: url, type: .video)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if(copied) {
                sharedAttachments.append(SharedAttachment.init(path:  newFileUrl.absoluteString, type: .video))
            }
        } else {
            dismissWithError()
        }

    }

    public func handleFiles (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: fileURLType, options: nil)

        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from :url, type: .file)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if (copied) {
                sharedAttachments.append(SharedAttachment.init(path:  newFileUrl.absoluteString, type: .file))
            }
        } else {
            dismissWithError()
        }

    }

    public func handleData (content: NSExtensionItem, attachment: NSItemProvider, index: Int) async throws {
        let data = try await attachment.loadItem(forTypeIdentifier: dataContentType, options: nil)

        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from :url, type: .file)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if (copied) {
                sharedAttachments.append(SharedAttachment.init(path:  newFileUrl.absoluteString, type: .file))
            }
        } else {
            dismissWithError()
        }

    }

    public func dismissWithError() {
        print("[ERROR] Error loading data!")
        let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    public func redirectToHostApp() {
        // ids may not loaded yet so we need loadIds here too
        loadIds();
        let url = URL(string: "ShareMedia-\(ShareHandlerIosViewController.hostAppBundleIdentifier)://\(ShareHandlerIosViewController.hostAppBundleIdentifier)?key=\(sharedKey)")
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")

        let intent = self.extensionContext?.intent as? INSendMessageIntent

        let conversationIdentifier = intent?.conversationIdentifier
        let sender = intent?.sender
        let serviceName = intent?.serviceName
        let speakableGroupName = intent?.speakableGroupName

        let sharedMedia = SharedMedia.init(attachments: sharedAttachments, conversationIdentifier: conversationIdentifier, content: sharedText.joined(separator: "\n"), speakableGroupName: speakableGroupName?.spokenPhrase, serviceName: serviceName, senderIdentifier: sender?.contactIdentifier ?? sender?.customIdentifier, imageFilePath: nil)

        let json = sharedMedia.toJson()

        userDefaults.set(json, forKey: sharedKey)
        userDefaults.synchronize()

        while (responder != nil) {
            if let application = responder as? UIApplication {
                if #available(iOS 18.0, *) {
                    let _ = application.open(url!, options: [:], completionHandler: nil)
                } else {
                    let _ = application.perform(selectorOpenURL, with: url)
                }
            }
            responder = responder?.next
        }
    }

    enum RedirectType {
        case media
        case text
        case file
    }

    func getExtension(from url: URL, type: SharedAttachmentType) -> String {
        let parts = url.lastPathComponent.components(separatedBy: ".")
        var ex: String? = nil
        if (parts.count > 1) {
            ex = parts.last
        }

        if (ex == nil) {
            switch type {
            case .image:
                ex = "PNG"
            case .video:
                ex = "MP4"
            case .file:
                ex = "TXT"
            default:
                ex = ""
            }
        }
        return ex ?? "Unknown"
    }

    func getFileName(from url: URL, type: SharedAttachmentType) -> String {
        var name = url.lastPathComponent
        if (name.isEmpty) {
            name = UUID().uuidString + "." + getExtension(from: url, type: type)
        }
        if let count = fileNameCounter[name] {
            fileNameCounter[name] = count + 1
            name = "\((name as NSString).deletingPathExtension)_\(count + 1).\((name as NSString).pathExtension)"
        } else {
            fileNameCounter[name] = 1
        }
        return name
    }

    func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}
