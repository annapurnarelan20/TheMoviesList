//
//  MovieListPresenter.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 19/04/22.
//

import Foundation

// MARK: - MovieListViewProtocol
protocol ListViewDelegate: AnyObject {
    func showLoader()
    func stopLoader()
    func showFailError(error: String)
    func handleMovieList(movieListModel: MovieListModel)
}

protocol MovieListPresenterProtocol: AnyObject {

    func getPopularMovieList()
}

class MovieListPresenter: MovieListPresenterProtocol {

    
    // MARK: - Stored Properties
    private let movieListApiService: MovieListApiService
    weak private var listViewDelegate: ListViewDelegate?

    
    init(listApiService: MovieListApiService) {
        self.movieListApiService = listApiService
    }
    
    func setViewDelegate(listViewDelegate: ListViewDelegate?){
        self.listViewDelegate = listViewDelegate
    }
    
    func getPopularMovieList() {
        listViewDelegate?.showLoader()
        movieListApiService.requestData(params: [:]) { resultType in
                    switch resultType
                    {
                    case .success(let listModel):
                    if let model = listModel as? MovieListModel
                    {
                        self.listViewDelegate?.stopLoader()
                        self.listViewDelegate?.handleMovieList(movieListModel: model)
                    }
                    case .failure(let error):
                        self.listViewDelegate?.showFailError(error: error.localizedDescription)
                    }
                }
    }
        
}

