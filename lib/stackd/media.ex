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
  end
end
