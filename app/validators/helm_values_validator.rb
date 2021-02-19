class HelmValuesValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless value.is_a? Hash
      record.errors.add :values, "Invalid Helm values"
    end
 end
end
