defmodule Stackd.Media do
  use Ash.Domain

  resources do
    resource Stackd.Media.Movie
    resource Stackd.Media.TvShow
    resource Stackd.Media.Game
    resource Stackd.Media.Album
    resource Stackd.Media.MovieLog
    resource Stackd.Media.TvShowLog
    resource Stackd.Media.GameLog
    resource Stackd.Media.AlbumLog
    resource Stackd.Media.MovieRating
    resource Stackd.Media.TvShowRating
    resource Stackd.Media.GameRating
    resource Stackd.Media.AlbumRating
    resource Stackd.Media.MovieReview
    resource Stackd.Media.TvShowReview
    resource Stackd.Media.GameReview
    resource Stackd.Media.AlbumReview
  end
end
