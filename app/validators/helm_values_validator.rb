class HelmValuesValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    unless value.is_a?(Hash)
      record.errors.add(:values, 'Invalid Helm Values')
    end
  end
end
