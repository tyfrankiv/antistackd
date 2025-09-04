# lib/stackd/media/tv_show_log.ex
defmodule Stackd.Media.TvShowLog do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "tv_show_logs"
    repo Stackd.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :rating, :integer do
      allow_nil? true
      constraints min: 1, max: 10
    end

    attribute :logged_date, :date do
      allow_nil? false
      default &Date.utc_today/0
    end

    attribute :notes, :string do
      allow_nil? true
    end

    attribute :is_rewatch, :boolean do
      allow_nil? false
      default false
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

    # Future: Connect to reviews
    #has_one :review, Stackd.Media.TvShowReview do
     # source_attribute :id
     # destination_attribute :tv_show_log_id
    #end
  end

  actions do
    defaults [:read]

    create :create do
      accept [:tv_show_id, :user_id, :rating, :logged_date, :notes, :is_rewatch]
      upsert? true
      upsert_identity :unique_user_tv_show_date
    end

    update :update do
      accept [:rating, :logged_date, :notes, :is_rewatch]
    end

    destroy :destroy
  end

  identities do
    identity :unique_user_tv_show_date, [:user_id, :tv_show_id, :logged_date]
  end

  policies do
    # Anyone can read logs (public like Letterboxd)
    policy action_type(:read) do
      authorize_if always()
    end

    # Only logged-in users can create logs
    policy action_type(:create) do
      authorize_if actor_present()
    end

    # Only the owner can update/delete their logs
    policy action_type([:update, :destroy]) do
      authorize_if actor_attribute_equals(:id, :user_id)
    end
  end
end
