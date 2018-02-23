class AsciicastPagePresenter
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  attr_reader :routes, :asciicast, :current_user, :policy, :playback_options

  delegate :download_filename, :width, :height, to: :asciicast, prefix: true

  def self.build(routes, asciicast, current_user, playback_options)
    decorated_asciicast = asciicast.decorate
    policy = Pundit.policy(current_user, asciicast)

    playback_options = {
      'theme' =>  decorated_asciicast.theme_name
    }.merge(playback_options)

    new(routes, decorated_asciicast, current_user, policy,
        PlaybackOptions.new(playback_options))
  end

  def initialize(routes, asciicast, current_user, policy, playback_options)
    @routes           = routes
    @asciicast        = asciicast
    @current_user     = current_user
    @policy           = policy
    @playback_options = playback_options
  end

  def title
    asciicast_title
  end

  def asciicast_title
    asciicast.title
  end

  def author_img_link
    asciicast.author_img_link
  end

  def author_link
    asciicast.author_link
  end

  def asciicast_created_at
    asciicast.created_at
  end

  def asciicast_env_details
    "#{asciicast.os} / #{asciicast.shell} / #{asciicast.terminal_type}"
  end

  def views_count
    asciicast.views_count
  end

  def show_admin_dropdown?
    [show_edit_link?,
     show_delete_link?,
     show_set_featured_link?,
     show_unset_featured_link?].any?
  end

  def show_edit_link?
    policy.update?
  end

  def show_delete_link?
    policy.destroy?
  end

  def show_set_featured_link?
    !asciicast.featured? && policy.change_featured?
  end

  def show_unset_featured_link?
    asciicast.featured? && policy.change_featured?
  end

  def show_make_private_link?
    !asciicast.private? && policy.change_visibility?
  end

  def show_make_public_link?
    asciicast.private? && policy.change_visibility?
  end

  def show_description?
    asciicast.description.present?
  end

  def description
    asciicast.description
  end

  def short_text_description
    if asciicast.description.present?
      truncate(strip_tags(asciicast.description).gsub(/\n+/, ' '), length: 200)
    else
      "Recorded by #{asciicast.user.display_name}"
    end
  end

  def other_asciicasts_by_author
    @other_asciicasts_by_author ||= author.other_asciicasts(asciicast, 3).decorate
  end

  def asciicast_oembed_url(format)
    routes.oembed_url(url: routes.asciicast_url(asciicast), format: format)
  end

  def show_private_label?
    asciicast.private?
  end

  def show_featured_label?
    asciicast.featured?
  end

  def asciicast_version
    asciicast.version
  end

  private

  def author
    asciicast.user
  end

end
