//
//  ItemRowView.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 27/10/2020.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var item: Item

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                Image(systemName: viewModel.icon)
                    .foregroundColor(viewModel.color.map { Color($0)} ?? .clear)
                // so if there is a string value for the color transform it into a color, if not use clear.
            }
        }
        .accessibilityLabel(viewModel.label)
    }
    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)
        self.item = item
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}
