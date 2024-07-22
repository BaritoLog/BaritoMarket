# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::AppGroupsController < Api::BaseController
  include Wisper::Publisher

  def fetch_redact_labels

    if Figaro.env.MARKET_REDACT_CLIENT_KEY != params[:client_key]
      render(json: {
               success: false,
               errors: ['Unauthorized'],
               code: 401,
             }, status: :not_found) && return
    end

    helm_infrastructure = HelmInfrastructure.find_by(
      cluster_name: params[:cluster_name])

    redact_response_json = REDIS_CACHE.get(
      "#{APP_GROUP_REDACT_LABELS}:#{params[:cluster_name]}")
    if redact_response_json.present?
      render json: JSON.parse(redact_response_json) and return
    end

    all_labels = {}
    app_group = AppGroup.find(helm_infrastructure.app_group_id)
    if app_group.blank? || !app_group.available?
      render json: {
        success: false,
        errors: ['AppGroup not found or inactive'],
        code: 404
      }, status: :not_found and return
    end

    if !app_group.redact_active?
      render json: {} and return 
    end
    
    static, jsonPath = accumulate_rules(app_group)
    all_labels['default'] = {
      StaticRules: static,
      JsonPathRules: jsonPath,
    }

    barito_apps =[]
    app_group.barito_apps.where(status:"ACTIVE").each do |barito_app|
      static, jsonPath = accumulate_rules(barito_app)
      if !static.empty? || !jsonPath.empty?
        all_labels[barito_app.name] = {
          StaticRules: static,
          JsonPathRules: jsonPath,
        }
      end
    end

    broadcast(:redact_response_updated, params[:cluster_name], all_labels)

    render json: all_labels
  end

  private

  def accumulate_rules(obj)
    static_rule = []
    json_path_rule = []
    
    obj.redact_labels&.each do |key, val| 
      if val['type'] == 'jsonPath'
        json_path_rule << {
          Name: key,
          Path: val['value'],
          HintCharsStart: Integer(val['hintCharStart']),
          HintCharsEnd: Integer(val['hintCharEnd'])
        }
      elsif val['type'] == 'static'
        static_rule << {
          Name: key,
          Regex: val['value'],
          HintCharsStart: Integer(val['hintCharStart']),
          HintCharsEnd: Integer(val['hintCharEnd'])
        }
      end 
    end
    [static_rule, json_path_rule] 
  end
end
