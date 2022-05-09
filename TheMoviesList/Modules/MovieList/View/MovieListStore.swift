//
//
//  Created by Annapurna Relan on 19/03/22.
//

import Combine
import SwiftUI

class MovieListStore: ObservableObject {

    @Published var movieList : [ResponseData] = []
    @Published var imagePath : String = ""
    @Published var modelList : MovieListModel?
    @Published var movieImageName = [String]()
    @Published var watchAgain = [String]()
    @Published var cover1 = [String]()
    @Published var cover2 = [String]()
    @Published var cover3 = [String]()
    @Published var showActIndicator: Bool = false
    private var presenter = MovieListPresenter(listApiService: MovieListApiService())
   
    init() {
        onLoad()
      }
    
    func onLoad() {
        showActIndicator = true
        self.presenter.setViewDelegate(listViewDelegate: self)
        self.presenter.getPopularMovieList()
    }
    
}

extension MovieListStore: ListViewDelegate {
    
    func showLoader() {
        showActIndicator = true
    }
    
    func stopLoader() {
        showActIndicator = false
    }
    
    func showFailError(error: String) {
        showActIndicator = false
    }
    
    func handleMovieList(movieListModel: MovieListModel) {
        showActIndicator = false
        self.modelList = movieListModel
        self.movieList = modelList?.responseData ?? []
        movieImageName = self.movieList.map({$0.image ?? ""})
        watchAgain = [movieImageName[3] , movieImageName[2] , movieImageName[6]]
        cover1 = stride(from: 1, to: movieImageName.count, by: 2).map { movieImageName[$0] }
        cover2 = stride(from: 0, to: movieImageName.count, by: 2).map { movieImageName[$0] }
        cover3 = cover1 + cover2
    }
  
}
