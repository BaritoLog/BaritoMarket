class ProfileController < BaseController
    skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
    
    def authenticate_cas
        username = User.authenticate_cas request.env["HTTP_AUTHORIZATION"]
    
        ## cas-5.1.x expects {"@c":".SimplePrincipal","id":"casuser","attributes":{}}
        response_map = {
          "@class":"org.apereo.cas.authentication.principal.SimplePrincipal",
          "id" => username,
          "attributes": {"backend": "baritolog"}
        }
    
        if username.present?
          render json: response_map, status: :ok
        else
          render json: response_map, status: 401
        end
      end
end