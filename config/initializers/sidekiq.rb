#
# Init Repeating Jobs
#
::Sidekiq::Cron::Job.destroy_all!

::Sidekiq::Cron::Job.create(
  :name =>'Kickoff sync and predictor - Every day at 6pm',
  :cron => '0 18 * * *',
  :klass => 'KickoffWorker')
