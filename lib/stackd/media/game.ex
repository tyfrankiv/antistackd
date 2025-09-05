defmodule Stackd.Media.Game do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "games"
    repo Stackd.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:rawg_id, :name, :description, :poster_path, :backdrop_path, :released, :genres]
    end
  end

  attributes do
    uuid_primary_key :id

    # Data from RAWG API
    attribute :rawg_id, :integer, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :description, :string

    # Cover art
    attribute :poster_path, :string

    # Screenshot/hero image
    attribute :backdrop_path, :string
    attribute :released, :date
    attribute :genres, {:array, :string}, default: []

    # Metadata
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :ratings, Stackd.Media.GameRating do
      source_attribute :id
      destination_attribute :game_id
    end

    has_many :logs, Stackd.Media.GameLog do
      source_attribute :id
      destination_attribute :game_id
    end

    has_many :reviews, Stackd.Media.GameReview do
      source_attribute :id
      destination_attribute :game_id
    end
  end

  aggregates do
    avg :average_rating, :ratings, :rating
  end

  identities do
    identity :unique_rawg_id, [:rawg_id]
  end
end
