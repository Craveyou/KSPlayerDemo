//
//  FilesView.swift
//  TracyPlayer
//
//  Created by kintan on 2023/7/3.
//

import KSPlayer
import SwiftUI

struct FilesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \M3UModel.name, ascending: true)],
        predicate: NSPredicate(format: "m3uURL != nil && name != nil")
    )
    private var m3uModels: FetchedResults<M3UModel>
    @EnvironmentObject
    private var appModel: APPModel
    @State
    private var addM3U = false
    @State
    private var openFileImport = false
    @State
    private var nameFilter: String = ""
    var body: some View {
        let models = m3uModels.filter { model in
            var isIncluded = true
            if !nameFilter.isEmpty {
                isIncluded = model.name!.contains(nameFilter)
            }
            return isIncluded
        }
        #if os(tvOS)
        HStack {
            toolbarView
        }
        #endif
        List(models, id: \.self, selection: $appModel.activeM3UModel) { model in
            #if os(tvOS)
            NavigationLink(value: model) {
                M3UView(model: model)
            }
            #else
            M3UView(model: model)
            #endif
        }
        .searchable(text: $nameFilter)
        .sheet(isPresented: $addM3U) {
            AddM3UView()
        }
        #if !os(tvOS)
        .toolbar {
            toolbarView
        }
        .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.data]) { result in
            guard let url = try? result.get() else {
                return
            }
            appModel.addM3U(url: url)
        }
        #endif
    }

    private var toolbarView: some View {
        Group {
            Button {
                openFileImport = true
            } label: {
                Label("添加本地 M3U", systemImage: "plus.rectangle.on.folder.fill")
            }
            #if !os(tvOS)
            .keyboardShortcut("o")
            #endif
            Button {
                addM3U = true
            } label: {
                Label("添加远程 M3U", systemImage: "plus.app.fill")
            }
            #if !os(tvOS)
            .keyboardShortcut("o", modifiers: [.command, .shift])
            #endif
        }
        .labelStyle(.titleAndIcon)
    }
}

struct M3UView: View {
    @ObservedObject
    var model: M3UModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.name ?? "")
                .font(.title2)
                .foregroundColor(.primary)
            Text("共 \(model.count) 个频道")
                .font(.callout)
                .foregroundColor(.secondary)
            Text(model.m3uURL?.description ?? "")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .contextMenu {
            if PersistenceController.shared.container.canUpdateRecord(forManagedObjectWith: model.objectID) {
                Button {
                    model.delete()
                } label: {
                    Label("删除", systemImage: "trash.fill")
                }
            }
            Button {
                Task {
                    try? await _ = model.parsePlaylist()
                }
            } label: {
                Label("刷新", systemImage: "arrow.clockwise.circle")
            }
            #if !os(tvOS)
            Button {
                #if os(macOS)
                UIPasteboard.general.clearContents()
                UIPasteboard.general.setString(model.m3uURL!.description, forType: .string)
                #else
                UIPasteboard.general.setValue(model.m3uURL!, forPasteboardType: "public.url")
                #endif
            } label: {
                Label("复制链接", systemImage: "doc.on.doc.fill")
            }
            #endif
        }
    }
}

struct AddM3UView: View {
    #if DEBUG && targetEnvironment(simulator)
    @State
    private var url = "https://raw.githubusercontent.com/kingslay/TestVideo/main/TestVideo.m3u"
    #else
    @State
    private var url = ""
    #endif
    @State
    private var name = ""
    @EnvironmentObject private var appModel: APPModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section {
                TextField("链接", text: $url)
                TextField("名称", text: $name)
            }
            Section {
                Text("你添加的播放列表链接是公开的，所有人都能看到，但只有你能修改和删除")
                Button("完成") {
                    if let url = URL(string: url.trimmingCharacters(in: NSMutableCharacterSet.whitespacesAndNewlines)) {
                        let name = name.trimmingCharacters(in: NSMutableCharacterSet.whitespacesAndNewlines)
                        appModel.addM3U(url: url, name: name.isEmpty ? nil : name)
                    }
                    dismiss()
                }
                #if !os(tvOS)
                .keyboardShortcut(.defaultAction)
                #endif
                #if os(macOS) || targetEnvironment(macCatalyst)
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                #endif
            }
        }.padding()
    }
}
