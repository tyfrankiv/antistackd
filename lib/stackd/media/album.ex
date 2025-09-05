defmodule Stackd.Media.Album do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Stackd.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:spotify_id, :name, :artist, :poster_path, :backdrop_path, :release_date, :genres]
    end
  end

  attributes do
    uuid_primary_key :id

    # Data from Spotify API
    attribute :spotify_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :artist, :string, allow_nil?: false

    # Album cover (square)
    attribute :poster_path, :string

    # Artist photo or similar
    attribute :backdrop_path, :string
    attribute :release_date, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :ratings, Stackd.Media.AlbumRating do
      source_attribute :id
      destination_attribute :album_id
    end

    has_many :logs, Stackd.Media.AlbumLog do
      source_attribute :id
      destination_attribute :album_id
    end

    has_many :reviews, Stackd.Media.AlbumReview do
      source_attribute :id
      destination_attribute :album_id
    end
  end

  aggregates do
    avg :average_rating, :ratings, :rating
  end

  identities do
    identity :unique_spotify_id, [:spotify_id]
  end
end
