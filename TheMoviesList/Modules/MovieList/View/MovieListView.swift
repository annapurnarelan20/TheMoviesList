//
//  ContentView.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 19/04/22.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var movieListStore = MovieListStore()
  
    var body: some View {
      
        GeometryReader{screenSize in
            ZStack{
                ScrollView(showsIndicators: false){
                    VStack(spacing:20){
                        Image(movieListStore.movieImageName[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenSize.size.width, height: 600)
                            .background(Color.white)
                            .clipped()
                        
                        moviesRow(title: "Watch Again", coverString: movieListStore.watchAgain)
                        
                        moviesRow(title: "Movies", coverString: movieListStore.cover1)
                        
                        moviesRow(title: "Series", coverString: movieListStore.cover2)
                        
                        moviesRow(title: "All", coverString: movieListStore.cover3)
                    }.padding(.bottom , 30)
                }
                VStack{
                    Spacer()
                }
            }.background(Color.black.ignoresSafeArea())
                .statusBar(hidden: true)
        }

        
        
    }
    
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}



