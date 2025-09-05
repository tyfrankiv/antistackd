defmodule Stackd.Media.Movie do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "movies"
    repo Stackd.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:tmdb_id, :title, :overview, :poster_path, :backdrop_path, :release_date, :genres]
    end
  end

  attributes do
    uuid_primary_key :id

    # Data from TMDB API
    attribute :tmdb_id, :integer, allow_nil?: false
    attribute :title, :string, allow_nil?: false
    attribute :overview, :string
    attribute :poster_path, :string

    # Hero background image
    attribute :backdrop_path, :string
    attribute :release_date, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :ratings, Stackd.Media.MovieRating do
      source_attribute :id
      destination_attribute :movie_id
    end

    has_many :logs, Stackd.Media.MovieLog do
      source_attribute :id
      destination_attribute :movie_id
    end

    has_many :reviews, Stackd.Media.MovieReview do
      source_attribute :id
      destination_attribute :movie_id
    end
  end

  aggregates do
    avg :average_rating, :ratings, :rating
  end

  identities do
    identity :unique_tmdb_id, [:tmdb_id]
  end
end
