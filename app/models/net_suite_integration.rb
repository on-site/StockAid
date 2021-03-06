module NetSuiteIntegration
  EXPORT_QUEUED_EXTERNAL_ID = -1
  EXPORT_IN_PROGRESS_EXTERNAL_ID = -2
  EXPORT_FAILED_EXTERNAL_ID = -3

  def self.host
    "#{NetSuite::Configuration.account}.app.netsuite.com"
  end

  def self.path(object)
    case object
    when Order
      "https://#{host}/app/accounting/transactions/custinvc.nl?id=#{object.external_id}"
    when Donation
      "https://#{host}/app/accounting/transactions/cashsale.nl?id=#{object.external_id}"
    when Donor
      "https://#{host}/app/common/entity/contact.nl?id=#{object.external_id}"
    when Organization
      "https://#{host}/app/common/entity/custjob.nl?id=#{object.external_id}"
    end
  end

  def self.export_queued(object)
    object.external_id = NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID
    object.save!
  end

  def self.export_queued?(object)
    object.external_id == NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID
  end

  def self.export_in_progress(object)
    object.external_id = NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID
    object.save!
  end

  def self.export_in_progress?(object)
    object.external_id == NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID
  end

  def self.export_failed(object)
    object.external_id = NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID
    object.save!
  end

  def self.export_failed?(object)
    object.external_id == NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID
  end

  def self.exported_successfully?(object)
    object.external_id && object.external_id > 0
  end
end
