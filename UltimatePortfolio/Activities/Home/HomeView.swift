//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 24/10/2020.
//
import CoreData
import CoreSpotlight
import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject var viewModel: ViewModel

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        NavigationView {
            ScrollView {

                if let item = viewModel.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    )
                    .id(item)
                }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: $viewModel.upNext)
                        ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
                    }
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                // Button("Add Data", action: viewModel.addSampleData)
                Button("Delete All", action: viewModel.dataController.deleteAll)
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier) // Paul has selectItem and not selectedItem
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
