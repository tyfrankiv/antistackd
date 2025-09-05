defmodule Stackd.Media.Notifiers.StatsNotifier do
  use Ash.Notifier

  def notify(%Ash.Notifier.Notification{resource: resource, action: %{type: action_type}} = notification)
      when action_type in [:create, :update, :destroy] do

    media_type = get_media_type(resource)
    media_id = get_media_id_from_notification(notification, resource)

    if media_id do
      Phoenix.PubSub.broadcast(
        Stackd.PubSub,
        "media:#{media_type}:#{media_id}",
        {:media_updated, media_type, media_id}
      )
    end

    :ok
  end

  def notify(_), do: :ok

  defp get_media_type(Stackd.Media.MovieRating), do: "movie"
  defp get_media_type(Stackd.Media.MovieLog), do: "movie"
  defp get_media_type(Stackd.Media.MovieReview), do: "movie"
  defp get_media_type(Stackd.Media.AlbumRating), do: "album"
  defp get_media_type(Stackd.Media.AlbumLog), do: "album"
  defp get_media_type(Stackd.Media.AlbumReview), do: "album"
  defp get_media_type(Stackd.Media.GameRating), do: "game"
  defp get_media_type(Stackd.Media.GameLog), do: "game"
  defp get_media_type(Stackd.Media.GameReview), do: "game"
  defp get_media_type(Stackd.Media.TvShowRating), do: "tv_show"
  defp get_media_type(Stackd.Media.TvShowLog), do: "tv_show"
  defp get_media_type(Stackd.Media.TvShowReview), do: "tv_show"

  defp get_media_id_from_notification(notification, resource) do
    data = notification.data || notification.changeset.data

    case resource do
      r when r in [Stackd.Media.MovieRating, Stackd.Media.MovieLog, Stackd.Media.MovieReview] ->
        data.movie_id
      r when r in [Stackd.Media.AlbumRating, Stackd.Media.AlbumLog, Stackd.Media.AlbumReview] ->
        data.album_id
      r when r in [Stackd.Media.GameRating, Stackd.Media.GameLog, Stackd.Media.GameReview] ->
        data.game_id
      r when r in [Stackd.Media.TvShowRating, Stackd.Media.TvShowLog, Stackd.Media.TvShowReview] ->
        data.tv_show_id
      _ -> nil
    end
  end
end
