class CalculatorsController < ApplicationController
	def calculate
	end

	def calculate_price
    price_per_gb = Figaro.env.PRICE_PER_GB.to_f
    std_retention = Figaro.env.STANDARD_RETENTION.to_f
    std_replication = Figaro.env.STANDARD_REPLICATION.to_f
    retention_multiplier = ((app_params[:retention].to_f - std_retention) / std_retention)
    replication_multiplier = ((app_params[:replication].to_f - std_replication) / std_replication)
    @price = sprintf("%0.9f", price_per_gb * app_params[:log_bytes].to_f * (1 + retention_multiplier + replication_multiplier))
    render json: @price
	end

	private
		def app_params
			params.require(:instance).permit(
				:log_bytes,
				:retention,
				:replication,
			)
		end
end
