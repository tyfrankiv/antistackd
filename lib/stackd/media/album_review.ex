defmodule Stackd.Media.AlbumReview do
  use Ash.Resource,
    domain: Stackd.Media,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "album_reviews"
    repo Stackd.Repo

    references do
      reference :user, on_delete: :delete
      reference :album, on_delete: :delete
      reference :album_log, on_delete: :delete
    end

    check_constraints do
      check_constraint :content,
        name: "content_not_empty",
        check: "length(trim(content)) > 0"
    end

    custom_indexes do
      index [:user_id, :album_id],
        unique: true,
        where: "album_log_id IS NULL"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
      constraints max_length: 50_000
    end

    attribute :rating, :integer do
      allow_nil? true
      constraints min: 1, max: 10
    end

    attribute :spoiler, :boolean do
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

    belongs_to :album_log, Stackd.Media.AlbumLog do
      allow_nil? true
    end
  end

  validations do
    validate {Stackd.Accounts.Validations.TextSanitizationValidation, field: :content}
  end

  actions do
    defaults [:read]

    create :create do
      accept [:album_id, :album_log_id, :content, :rating, :spoiler]
      change set_attribute(:user_id, actor(:id))
      change after_action(&update_user_rating/3)
    end

    update :update do
      accept [:content, :rating, :spoiler]
      change after_action(&update_user_rating/3)
      require_atomic? false
    end

    destroy :destroy
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type([:update, :destroy]) do
      authorize_if actor_attribute_equals(:id, :user_id)
    end
  end

  defp update_user_rating(_changeset, review, _context) do
    if review.rating do
      case Stackd.Media.AlbumRating
           |> Ash.Changeset.for_create(:create, %{
             user_id: review.user_id,
             album_id: review.album_id,
             rating: review.rating
           })
           |> Ash.create() do
        {:ok, _rating} -> {:ok, review}
        {:error, error} -> {:error, error}
      end
    else
      {:ok, review}
    end
  end
end
