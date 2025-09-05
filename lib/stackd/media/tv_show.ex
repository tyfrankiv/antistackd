defmodule Stackd.Media.TvShow do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tv_shows"
    repo Stackd.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:tmdb_id, :name, :overview, :poster_path, :backdrop_path, :first_air_date, :genres]
    end
  end

  attributes do
    uuid_primary_key :id

    # Data from TMDB API
    attribute :tmdb_id, :integer, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :overview, :string
    attribute :poster_path, :string

    # Hero background image
    attribute :backdrop_path, :string
    attribute :first_air_date, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :ratings, Stackd.Media.TvShowRating do
      source_attribute :id
      destination_attribute :tv_show_id
    end

    has_many :logs, Stackd.Media.TvShowLog do
      source_attribute :id
      destination_attribute :tv_show_id
    end

    has_many :reviews, Stackd.Media.TvShowReview do
      source_attribute :id
      destination_attribute :tv_show_id
    end
  end

  aggregates do
    avg :average_rating, :ratings, :rating
  end

  identities do
    identity :unique_tmdb_id, [:tmdb_id]
  end
end
