module ApplicationHelper
  def turbo_train_from(*streamables, **attributes)
    attributes[:name] = Turbo::Train.signed_stream_name(streamables)
    attributes[:session] = Turbo::Train.encode({ platform: "web" })
    attributes[:href] = Turbo::Train.url
    tag.turbo_train_stream_source(**attributes)
  end
end
