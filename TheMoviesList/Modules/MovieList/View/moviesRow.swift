//
//  moviesView.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 19/04/22.
//

import SwiftUI

struct moviesRow: View {
    
    @StateObject private var movieListStore = MovieListStore()
    let title: String
    let coverString:[String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).foregroundColor(.white)
            ScrollView(.horizontal , showsIndicators: false){
                HStack(spacing: 15){
                    ForEach(coverString , id:\.self){ coverString in
                        Image(coverString)
                            .resizable()
                            //.frame(width: 140, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(.horizontal , 5)
            }
        }
    }
}

struct moviesRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            moviesRow(title: "Movies", coverString: [])
        }
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}
