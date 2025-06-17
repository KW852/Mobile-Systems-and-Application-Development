//
//  ContentView.swift
//  Calculator2025
//
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct ContentView: View {
    
    @State var value = "0"
    @State var isUserEnteringNumber = false
    @StateObject private var calculatorVM = CalculatorViewModel()
    @State private var orientation = UIDeviceOrientation.unknown

    func buttonWidth(item: CalcuButton) -> CGFloat {
        if orientation.isLandscape {
            let width: CGFloat
            if UIDevice.current.userInterfaceIdiom == .pad {
                width = 500 / 4
            } else {
                width = (UIScreen.main.bounds.width - (3 * 14)) / 18
            }
            if calculatorVM.selectedMode == .dec && item == .zero {
                return width * 2.15
            }
            if calculatorVM.selectedMode == .hex && item == .clear {
                return width * 2.15
            }
            if calculatorVM.selectedMode == .hex && item == .equal {
                return width * 2.15
            }
            return width
        } else {
            let width: CGFloat
            if UIDevice.current.userInterfaceIdiom == .pad {
                width = 500 / 4
            } else {
                width = (UIScreen.main.bounds.width - (5 * 24)) / 4
            }
            if calculatorVM.selectedMode == .dec && item == .zero {
                return width * 2.15
            }
            if calculatorVM.selectedMode == .hex && item == .zero {
                return width
            }
            return width
        }
    }

    func buttonHeight() -> CGFloat {
        if orientation.isLandscape {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 500 / 5
            } else {
                return (UIScreen.main.bounds.height - (3 * 14)) / 8
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 500 / 4
            } else {
                return (UIScreen.main.bounds.width - (5 * 24)) / 4
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                if orientation.isLandscape {
                    VStack(spacing: 10) {
                        Text("Mode: \(calculatorVM.selectedMode.rawValue)")
                            .bold()
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Picker("Mode", selection: $calculatorVM.selectedMode) {
                            ForEach(CalculatorMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.blue.opacity(0.9))
                        .padding(.horizontal)
                        
                        Text(calculatorVM.expression)
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)

                        HStack {
                            Spacer()
                            Text(calculatorVM.displayValue)
                                .bold()
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        VStack {
                            ForEach(calculatorVM.buttons, id: \.self) { row in
                                HStack(spacing: 12) {
                                    ForEach(row, id: \.self) { item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 26))
                                                .frame(width: self.buttonWidth(item: item),
                                                       height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 3)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 10)
                    }
                } else {
                    VStack {
                        Text("Mode: \(calculatorVM.selectedMode.rawValue)")
                            .bold()
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Picker("Mode", selection: $calculatorVM.selectedMode) {
                            ForEach(CalculatorMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.blue.opacity(0.9))
                        .padding()
                        
                        Text(calculatorVM.expression)
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            Text(calculatorVM.displayValue)
                                .bold()
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        ForEach(calculatorVM.buttons, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.self) { item in
                                    Button(action: {
                                        calculatorVM.didTap(button: item)
                                        print(item.rawValue)
                                    }, label: {
                                        Text(item.rawValue)
                                            .font(.system(size: 32))
                                            .frame(width: self.buttonWidth(item: item),
                                                   height: self.buttonHeight())
                                            .background(item.buttonColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(self.buttonHeight() / 2)
                                    })
                                }
                            }
                            .padding(.bottom, 3)
                        }
                    }
                }
            }
        }
        .onRotate { newOrientation in
            DispatchQueue.main.async {
                let isNowLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
                if isNowLandscape != calculatorVM.isLandscape {
                    calculatorVM.isLandscape = isNowLandscape
                    orientation = newOrientation
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
