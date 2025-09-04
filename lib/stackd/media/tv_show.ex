defmodule Stackd.Media.TvShow do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tv_shows"
    repo Stackd.Repo
  end

  attributes do
    uuid_primary_key :id

    # Data from TMDB API
    attribute :tmdb_id, :integer, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :overview, :string
    attribute :poster_path, :string
    attribute :backdrop_path, :string  # Hero background image
    attribute :first_air_date, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    create :create do
      accept [:tmdb_id, :name, :overview, :poster_path, :backdrop_path, :first_air_date, :genres]
    end
  end

  identities do
    identity :unique_tmdb_id, [:tmdb_id]
  end
end
