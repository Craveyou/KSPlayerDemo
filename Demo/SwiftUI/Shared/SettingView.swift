//
//  SettingView.swift
//  TracyPlayer
//
//  Created by kintan on 2023/6/21.
//

import KSPlayer
import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingGeneralView()) {
                    Label("通用", systemImage: "switch.2")
                }
                NavigationLink(destination: SettingAudioView()) {
                    Label("音频", systemImage: "waveform")
                }
                NavigationLink(destination: SettingVideoView()) {
                    Label("视频", systemImage: "play.rectangle.fill")
                }
                NavigationLink(destination: SettingSubtitleView()) {
                    Label("字幕", systemImage: "captions.bubble")
                }
                NavigationLink(destination: SettingAdvancedView()) {
                    Label("高级", systemImage: "gearshape.2.fill")
                }
            }
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
}

struct SettingGeneralView: View {
    @Default(\.showRecentPlayList)
    private var showRecentPlayList
    var body: some View {
        Form {
            Toggle("显示最近播放列表", isOn: $showRecentPlayList)
        }
    }
}

struct SettingAudioView: View {
    @Default(\.audioPlayerType)
    private var audioPlayerType
    init() {}
    var body: some View {
        Form {
            Picker("音频播放器类型", selection: $audioPlayerType) {
                Text("AUGraph").tag(NSStringFromClass(AudioGraphPlayer.self))
                Text("AudioUnit").tag(NSStringFromClass(AudioUnitPlayer.self))
                Text("AVAudioEngine").tag(NSStringFromClass(AudioEnginePlayer.self))
            }
        }
    }
}

struct SettingVideoView: View {
    @Default(\.hardwareDecode)
    private var hardwareDecode
    @Default(\.asynchronousDecompression)
    private var asynchronousDecompression
    @Default(\.isUseDisplayLayer)
    private var isUseDisplayLayer
    @Default(\.yadifMode)
    private var yadifMode
    var body: some View {
        Form {
            Toggle("硬件解码", isOn: $hardwareDecode)
            Toggle("异步解码", isOn: $asynchronousDecompression)
            Toggle("使用 DisplayLayer", isOn: $isUseDisplayLayer)
            Picker("yadif 模式", selection: $yadifMode) {
                Text("yadif").tag(0)
                Text("yadif_2x").tag(1)
                Text("yadif_spatial_skip").tag(2)
                Text("yadif_2x_spatial_skip").tag(3)
            }
        }
    }
}

struct SettingSubtitleView: View {
    @Default(\.textFontSize)
    private var textFontSize
    @Default(\.textBold)
    private var textBold
    @Default(\.textItalic)
    private var textItalic
    @Default(\.textColor)
    private var textColor
    @Default(\.textBackgroundColor)
    private var textBackgroundColor
    @Default(\.verticalAlign)
    private var verticalAlign
    @Default(\.horizontalAlign)
    private var horizontalAlign
    @Default(\.leftMargin)
    private var leftMargin
    @Default(\.rightMargin)
    private var rightMargin
    @Default(\.verticalMargin)
    private var verticalMargin
    var body: some View {
        Form {
            Section("字幕排版") {
                HStack {
                    #if os(iOS)
                    Text("字号：")
                    #endif
                    TextField("字号：", value: $textFontSize, format: .number)
                }
                Toggle("加粗", isOn: $textBold)
                Toggle("斜体", isOn: $textItalic)
                #if !os(tvOS)
                ColorPicker("颜色：", selection: $textColor)
                ColorPicker("背景：", selection: $textBackgroundColor)
                #endif
            }
            Section("位置") {
                Picker("水平对齐：", selection: $horizontalAlign) {
                    ForEach([HorizontalAlignment.leading, .center, .trailing]) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                Picker("垂直对齐：", selection: $verticalAlign) {
                    ForEach([VerticalAlignment.top, .center, .bottom]) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                HStack {
                    #if os(iOS)
                    Text("左边距：")
                    #endif
                    TextField("左边距：", value: $leftMargin, format: .number)
                }
                HStack {
                    #if os(iOS)
                    Text("右边距：")
                    #endif
                    TextField("右边距：", value: $rightMargin, format: .number)
                }
                HStack {
                    #if os(iOS)
                    Text("垂直边距：")
                    #endif
                    TextField("垂直边距：", value: $verticalMargin, format: .number)
                }
            }
        }
        .padding()
    }
}

struct SettingAdvancedView: View {
    @Default(\.preferredForwardBufferDuration)
    private var preferredForwardBufferDuration
    @Default(\.maxBufferDuration)
    private var maxBufferDuration
    @Default(\.isLoopPlay)
    private var isLoopPlay
    @Default(\.canBackgroundPlay)
    private var canBackgroundPlay
    @Default(\.isAutoPlay)
    private var isAutoPlay
    @Default(\.isSecondOpen)
    private var isSecondOpen
    @Default(\.isAccurateSeek)
    private var isAccurateSeek
    @Default(\.isPipPopViewController)
    private var isPipPopViewController
//    @Default(\.isLoopPlay)
//    private var isLoopPlay
    var body: some View {
        Form {
            HStack {
                #if os(iOS)
                Text("预加载缓冲时长（秒）：")
                #endif
                TextField("预加载缓冲时长（秒）：", value: $preferredForwardBufferDuration, format: .number)
            }
            HStack {
                #if os(iOS)
                Text("最大缓冲时长（秒）：")
                #endif
                TextField("最大缓冲时长（秒）：", value: $maxBufferDuration, format: .number)
            }
            Toggle("循环播放", isOn: $isLoopPlay)
            Toggle("允许后台播放", isOn: $canBackgroundPlay)
            Toggle("自动播放", isOn: $isAutoPlay)
            Toggle("快速打开视频", isOn: $isSecondOpen)
            Toggle("精确拖动定位", isOn: $isAccurateSeek)
            Toggle("画中画内联", isOn: $isPipPopViewController)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
