# lib/stackd/media/movie_rating.ex
defmodule Stackd.Media.TvShowRating do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "tv_show_ratings"
    repo Stackd.Repo

    references do
      reference :user, on_delete: :delete
      reference :tv_show, on_delete: :delete
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

    belongs_to :tv_show, Stackd.Media.TvShow do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]

    create :create do
      accept [:tv_show_id, :rating]
      change set_attribute(:user_id, actor(:id))
      upsert? true
      upsert_identity :unique_user_tv_show
    end

    update :update do
      accept [:rating]
    end

    destroy :destroy
  end

  identities do
    identity :unique_user_tv_show, [:user_id, :tv_show_id]
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
end
