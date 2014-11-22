module EventuallyTracker
  class Railtie < Rails::Railtie
    railtie_name :eventually_tracker

    config.after_initialize do
      EventuallyTracker.init
    end

    rake_tasks do
      load "tasks/eventually_tracker.rake"
    end
  end
end
