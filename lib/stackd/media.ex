defmodule Stackd.Media do
  use Ash.Domain

  resources do
    resource Stackd.Media.Movie
    resource Stackd.Media.MovieLog
    resource Stackd.Media.MovieReview
  end
end
