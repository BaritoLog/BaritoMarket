class UserGroupsController < ApplicationController
    respond_to :html, :json

    before_action :set_user_group, only: [:show, :edit, :update, :destroy]
  
    # GET /user_groups
    # GET /user_groups.json
    def index
      @user_groups = UserGroup.all
    end
  
    # GET /user_groups/1
    # GET /user_groups/1.json
    def show
    end
  
    # GET /user_groups/new
    def new
      @user_group = UserGroup.new
      respond_modal_with @user_group
    end
  
    # GET /user_groups/1/edit
    def edit
    end
  
    # POST /user_groups
    # POST /user_groups.json
    def create
      @user_group = UserGroup.new(user_group_params)
      @user_group.created_by = @current_user.id
      if request.xhr?
        if @user_group.save
          render :json => { :success => true, :user_group => @user_group }, status: :created
        else
          render json: @user_group.errors, status: :unprocessable_entity
        end
      else
        respond_to do |format|
          if @user_group.save
            format.html { redirect_to @user_group, notice: 'user group was successfully created.' }
            format.json { render :show, status: :created, location: @user_group }
          else
            format.html { render :new }
            format.json { render json: @user_group.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  
    # PATCH/PUT /user_groups/1
    # PATCH/PUT /user_groups/1.json
    def update
      respond_to do |format|
        if @user_group.update(user_group_params)
          format.html { redirect_to @user_groups, notice: 'user group was successfully updated.' }
          format.json { render :show, status: :ok, location: @user_group }
        else
          format.html { render :edit }
          format.json { render json: @user_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /user_groups/1
    # DELETE /user_groups/1.json
    def destroy
      @user_group.destroy
      respond_to do |format|
        format.html { redirect_to user_group_url, notice: 'user group was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user_group
        @user_group = UserGroup.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def user_group_params
        params.require(:user_group).permit(:name)
      end
  end
  