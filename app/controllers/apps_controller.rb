class AppsController < ApplicationController
  def index
    @apps = BaritoApp.all
  end

  def new
    @app = BaritoApp.new
    @app_groups = Figaro.env.app_groups.split(',')
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")[Rails.env]
    @tps_options = config.keys.map(&:capitalize)
  end

  def create
    @app = BaritoApp.setup(
      barito_app_params[:name],
      barito_app_params[:tps_config].downcase,
      barito_app_params[:app_group].downcase,
    )

    if @app.valid?
      return redirect_to root_path
    else
      flash[:messages] = @app.errors.full_messages
      return redirect_to new_app_path
    end
  end

  def show
    @app = BaritoApp.find(params[:id])
  end

  private

  def barito_app_params
    params.require(:barito_app).permit(:name, :tps_config, :app_group)
  end
end
