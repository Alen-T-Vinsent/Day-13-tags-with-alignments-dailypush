//
//  ContentView.swift
//  Day-13-tags and tabs in Swift ui 4.0
//
//  Created by Apple  on 28/12/22.
//

import SwiftUI

struct ContentView: View {
    @State var tags:[Tag] = rawTags.compactMap{tag -> Tag? in
        return .init(name:tag)
    }
    //MARK: segment value
    @State var alignmentValue:Int = 1
    @State var text:String = ""
    var body: some View {
        
        NavigationStack{
            VStack{
                
                Picker("",selection:$alignmentValue){
                    Text("Leading")
                        .tag(0)
                    Text("Center")
                        .tag(1)
                    Text("Trailing")
                        .tag(2)
                    
                    
                }
                .pickerStyle(.segmented)
                .padding(.bottom,20)
                
                TagView(alignment: alignmentValue == 0 ? .leading : alignmentValue == 1 ? .center : .trailing, spacing: 20){
                    ForEach($tags){$tag in
                        //New Toggle API
                        Toggle(tag.name, isOn: $tag.isSelected)
                            .toggleStyle(.button)
                            .buttonStyle(.bordered)
                            .tint(tag.isSelected ? .red : .gray)
                    }
                }
                .animation(.interactiveSpring(response: 0.5,dampingFraction: 0.6,blendDuration: 0.6), value: alignmentValue)
                
                HStack{
                    //MARK: New Api
                    //Multiline TextField
                    TextField("Tag",text: $text,axis:.vertical)
                        .textFieldStyle(.roundedBorder)
                        //linelimit
                    //if it exceeds then it will enable scrollview
                        .lineLimit(1...5)
                    
                    Button("Add"){
                        withAnimation(.spring()){
                            tags.append(Tag(name:text))
                            text = ""
                        }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 4))
                    .tint(.red)
                    .disabled(text == "")
                }
                
               
            }
            .padding(15)
            .navigationTitle("Layout")
        }
        
    }
}

var rawTags:[String] = [
    "Swift UI","x code" , "Apple","WWDC 22","ios 16","ipad os 16","mac os 16","Api"]


//Mark: Building Custom layout with the new layout api
struct TagView:Layout{
    
    var alignment:Alignment = .center
    var spacing:CGFloat = 10
    //new x code will type all init by default
    //simply type init
    init(alignment:Alignment,spacing:CGFloat){
        self.alignment = alignment
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        //Returning default proposal layout
        return .init(width: proposal.width ?? 0 , height: proposal.height ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        //Placing view for spacing
        //for Testing
        //with customization and without customization
        
        
        //note origin
        //since origin will start from Applied Padding from parent view
        var origin = bounds.origin
        var maxWidth = bounds.width
        
        //MARK: Type:2
        var row:([LayoutSubviews.Element],Double) = ([],0.0)
        var rows:[([LayoutSubviews.Element],Double)] = []
        
        for view in subviews{
            
            let viewSize = view.sizeThatFits(proposal)
            
            if(origin.x + viewSize.width + spacing) > maxWidth{
                //this will give how much space remaining in a row
                row.1 = (bounds.maxX - origin.x + bounds.minX + spacing )
                rows.append(row)
                row.0.removeAll()
                //resetting horizontal axis
                origin.x = bounds.origin.x
                
                //next view
                row.0.append(view)
                origin.x += (viewSize.width + spacing)
                
            }else{
                row.0.append(view)
                origin.x += (viewSize.width + spacing)
            }
        }
        
        //MARK: Exhaust ones
        if !row.0.isEmpty{
            row.1 = (bounds.maxX - origin.x + bounds.minX + spacing)
            rows.append(row)
        }
        
        //MARK: Resetting origin
        origin = bounds.origin
        
        for row in rows{
            origin.x = (alignment == .leading ? bounds.minX : (alignment == .trailing ? row.1 : row.1/2))
            for view in row.0{
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }
            //Max height in the row
            let maxHeight = row.0.compactMap { view -> CGFloat? in
                return view.sizeThatFits(proposal).height
            }.max() ?? 0
            //updating origin view
            origin.y += (maxHeight + spacing)
            
        }
        
        
        //        //MARK: Type:1
        //        subviews.forEach { view in
        //            let viewSize = view.sizeThatFits(proposal)
        //
        //            //checking if view is going over MaxWidth
        //            if(origin.x + viewSize.width + spacing) > maxWidth{
        //                //Updating origin for next element in vertical order
        //                origin.y += (viewSize.height + spacing)
        //                //resetting horizontal axis
        //                origin.x = bounds.origin.x
        //
        //                //for next view which are stack
        //                //code in else
        //                view.place(at: origin, proposal: proposal)
        //                //updating origin for next view placement
        //                //adding spacing
        //                origin.x += (viewSize.width + spacing)
        //
        //            }else{
        //                view.place(at: origin, proposal: proposal)
        //                //updating origin for next view placement
        //                //adding spacing
        //                origin.x += (viewSize.width + spacing)
        //            }
        //
        //        }///subviews.forEach
    }
    
    
}

struct Tag:Identifiable{
    var id = UUID().uuidString
    var name:String
    var isSelected:Bool = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
