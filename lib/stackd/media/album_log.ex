# lib/stackd/media/album_log.ex
defmodule Stackd.Media.AlbumLog do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "album_logs"
    repo Stackd.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:album_id, :rating, :logged_date, :notes, :is_relisten]
      change set_attribute(:user_id, actor(:id))
      change after_action(&update_user_rating/3)
      upsert? true
      upsert_identity :unique_user_album_date
    end

    update :update do
      accept [:rating, :logged_date, :notes, :is_relisten]
      change after_action(&update_user_rating/3)
      require_atomic? false
    end

    destroy :destroy
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

    attribute :is_relisten, :boolean do
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

    belongs_to :album, Stackd.Media.Album do
      allow_nil? false
    end

    # Future: Connect to reviews
    has_one :review, Stackd.Media.AlbumReview do
      source_attribute :id
      destination_attribute :album_log_id
    end
  end

  identities do
    identity :unique_user_album_date, [:user_id, :album_id, :logged_date]
  end
  defp update_user_rating(_changeset, log, context) do
    if log.rating do
      case Stackd.Media.AlbumRating
      |> Ash.Changeset.for_create(:create, %{
        album_id: log.album_id,
        rating: log.rating
      })
      |> Ash.create(actor: context.actor) do
        {:ok, _rating} -> {:ok, log}
        {:error, error} -> {:error, error}
      end
    else
      {:ok, log}
    end
  end
end
