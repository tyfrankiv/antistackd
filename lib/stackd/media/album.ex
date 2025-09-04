defmodule Stackd.Media.Album do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Stackd.Repo
  end

  attributes do
    uuid_primary_key :id

    # Data from Spotify API
    attribute :spotify_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :artist, :string, allow_nil?: false
    attribute :poster_path, :string  # Album cover (square)
    attribute :backdrop_path, :string  # Artist photo or similar
    attribute :release_date, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    create :create do
      accept [:spotify_id, :name, :artist, :poster_path, :backdrop_path, :release_date, :genres]
    end
  end

  identities do
    identity :unique_spotify_id, [:spotify_id]
  end
end
