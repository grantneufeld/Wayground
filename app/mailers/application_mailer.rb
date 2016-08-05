# Base class for Mailers. Not yet modified from default Rails new project.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
