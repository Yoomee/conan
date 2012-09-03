unless (Rails.env.development? || Rails.env.test?)
  $AppName::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[$APP_NAME] ",
    :sender_address => "notifier <notifier@$app_name.yoomee.com>",
    :exception_recipients => %w{developers@yoomee.com}
end