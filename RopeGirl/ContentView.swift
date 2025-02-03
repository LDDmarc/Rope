import SwiftUI

struct ContentView: View {

    @State
    private var viewModel = ContentViewModel()

    var body: some View {
        GeometryReader { proxy in
            VStack {
                portrait
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { newValue in
                        viewModel.onSizeDidChange(newValue)
                    }
                    .offset(y: (proxy.size.height - proxy.size.width) / 2)
                Spacer()
                Text("Shake me")
                    .font(.largeTitle)
            }
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
        .animation(.snappy, value: viewModel.basePoints)
    }

    @ViewBuilder
    private var portrait: some View {
        ZStack {
            Image("girl")
                .resizable()
                .aspectRatio(contentMode: .fit)

            Rope(
                start: viewModel.startPoint,
                end: viewModel.endPoint,
                basePoints: viewModel.basePoints
            )?
                .stroke(Color.black, lineWidth: 7)
                .frame(width: viewModel.ropeWidth, height: viewModel.ropeHeight)
                .rotationEffect(.degrees(-90))
                .rotationEffect(.degrees(-10), anchor: .top)
                .offset(x: -(viewModel.ropeHeight/2.2))
                .offset(y: -0.09 * viewModel.ropeWidth)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

