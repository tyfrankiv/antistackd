# lib/stackd/media/album_rating.ex
defmodule Stackd.Media.AlbumRating do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "album_ratings"
    repo Stackd.Repo

    references do
      reference :user, on_delete: :delete
      reference :album, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    create :create do
      accept [:album_id, :rating]
      change set_attribute(:user_id, actor(:id))
      upsert? true
      upsert_identity :unique_user_album
    end

    update :update do
      accept [:rating]
    end

    destroy :destroy
  end

  policies do
    # Anyone can read ratings (public like Letterboxd)
    policy action_type(:read) do
      authorize_if always()
    end

    # Only logged-in users can create ratings
    policy action_type(:create) do
      authorize_if actor_present()
    end

    # Only the owner can update/delete their ratings
    policy action_type([:update, :destroy]) do
      authorize_if actor_attribute_equals(:id, :user_id)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :rating, :integer do
      allow_nil? true
      constraints min: 1, max: 10
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Stackd.Accounts.User do
      allow_nil? false
    end

    belongs_to :album, Stackd.Media.Album do
      allow_nil? false
    end
  end

  identities do
    identity :unique_user_album, [:user_id, :album_id]
  end
end
