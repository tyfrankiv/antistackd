# lib/stackd/media/notifiers/rating_notifier.ex
defmodule Stackd.Media.Notifiers.RatingNotifier do
  use Ash.Notifier
  require Ash.Query

  def notify(%Ash.Notifier.Notification{
    resource: resource,
    action: action,
    data: data
  }) do
    case {resource, action.name} do
      # Handle rating changes
      {rating_resource, :create} when rating_resource in [
        Stackd.Media.MovieRating,
        Stackd.Media.TvShowRating,
        Stackd.Media.AlbumRating,
        Stackd.Media.GameRating
      ] ->
        broadcast_rating_update(data, :created)

      {rating_resource, :update} when rating_resource in [
        Stackd.Media.MovieRating,
        Stackd.Media.TvShowRating,
        Stackd.Media.AlbumRating,
        Stackd.Media.GameRating
      ] ->
        broadcast_rating_update(data, :updated)

      {rating_resource, :destroy} when rating_resource in [
        Stackd.Media.MovieRating,
        Stackd.Media.TvShowRating,
        Stackd.Media.AlbumRating,
        Stackd.Media.GameRating
      ] ->
        broadcast_rating_update(data, :deleted)

      # Handle review changes
      {review_resource, :create} when review_resource in [
        Stackd.Media.MovieReview,
        Stackd.Media.TvShowReview,
        Stackd.Media.AlbumReview,
        Stackd.Media.GameReview
      ] ->
        broadcast_review_update(data, :created)

      {review_resource, :update} when review_resource in [
        Stackd.Media.MovieReview,
        Stackd.Media.TvShowReview,
        Stackd.Media.AlbumReview,
        Stackd.Media.GameReview
      ] ->
        broadcast_review_update(data, :updated)

      {review_resource, :destroy} when review_resource in [
        Stackd.Media.MovieReview,
        Stackd.Media.TvShowReview,
        Stackd.Media.AlbumReview,
        Stackd.Media.GameReview
      ] ->
        broadcast_review_update(data, :deleted)

      _ ->
        :ok
    end

    :ok
  end

  defp broadcast_rating_update(rating, action) do
    media_type = get_media_type_from_rating(rating)
    media_id = get_media_id_from_rating(rating)

    # Fetch updated media with new average rating
    media = fetch_media_with_average(media_type, media_id)

    Phoenix.PubSub.broadcast(
      Stackd.PubSub,
      "media:#{media_type}:#{media_id}",
      {:rating_updated, %{
        media: media,
        media_type: media_type,
        action: action,
        rating: rating
      }}
    )

    # Also broadcast to general media updates
    Phoenix.PubSub.broadcast(
      Stackd.PubSub,
      "media:updates",
      {:media_rating_updated, %{
        media_id: media_id,
        media_type: media_type,
        average_rating: media.average_rating
      }}
    )
  end

  defp broadcast_review_update(review, action) do
    media_type = get_media_type_from_review(review)
    media_id = get_media_id_from_review(review)

    Phoenix.PubSub.broadcast(
      Stackd.PubSub,
      "media:#{media_type}:#{media_id}:reviews",
      {:review_updated, %{
        review: review,
        media_type: media_type,
        action: action
      }}
    )

    Phoenix.PubSub.broadcast(
      Stackd.PubSub,
      "media:#{media_type}:#{media_id}",
      {:review_count_updated, %{
        media_id: media_id,
        media_type: media_type,
        action: action
      }}
    )
  end

  defp get_media_type_from_rating(%Stackd.Media.MovieRating{}), do: "movie"
  defp get_media_type_from_rating(%Stackd.Media.TvShowRating{}), do: "tv_show"
  defp get_media_type_from_rating(%Stackd.Media.AlbumRating{}), do: "album"
  defp get_media_type_from_rating(%Stackd.Media.GameRating{}), do: "game"

  defp get_media_type_from_review(%Stackd.Media.MovieReview{}), do: "movie"
  defp get_media_type_from_review(%Stackd.Media.TvShowReview{}), do: "tv_show"
  defp get_media_type_from_review(%Stackd.Media.AlbumReview{}), do: "album"
  defp get_media_type_from_review(%Stackd.Media.GameReview{}), do: "game"

  defp get_media_id_from_rating(rating) do
    case rating do
      %{movie_id: id} -> id
      %{tv_show_id: id} -> id
      %{album_id: id} -> id
      %{game_id: id} -> id
    end
  end

  defp get_media_id_from_review(review) do
    case review do
      %{movie_id: id} -> id
      %{tv_show_id: id} -> id
      %{album_id: id} -> id
      %{game_id: id} -> id
    end
  end

  defp fetch_media_with_average("movie", media_id) do
    Stackd.Media.Movie
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id == ^media_id)
    |> Ash.Query.load([:average_rating])
    |> Ash.read_one!()
  end

  defp fetch_media_with_average("tv_show", media_id) do
    Stackd.Media.TvShow
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id == ^media_id)
    |> Ash.Query.load([:average_rating])
    |> Ash.read_one!()
  end

  defp fetch_media_with_average("album", media_id) do
    Stackd.Media.Album
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id == ^media_id)
    |> Ash.Query.load([:average_rating])
    |> Ash.read_one!()
  end

  defp fetch_media_with_average("game", media_id) do
    Stackd.Media.Game
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id == ^media_id)
    |> Ash.Query.load([:average_rating])
    |> Ash.read_one!()
  end
end

# Add this to your media resources (in the `notifications` section):
#
# For example, in movie_rating.ex:
# notifications do
#   publish :create, ["rating_created", :movie_rating]
#   publish :update, ["rating_updated", :movie_rating]
#   publish :destroy, ["rating_deleted", :movie_rating]
# end
#
# And add the notifier:
# notifiers do
#   notifier Stackd.Media.Notifiers.RatingNotifier
# end
