class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def get_user_groups
    return false if user.nil?
    user_groups = []
    user.group_users.all.select { |gu| gu.expiration_date.nil? || (gu.expiration_date >= Time.now) }.each do |group_user|
      user_groups << group_user.group.name
    end
    return user_groups
  end

  def barito_superadmin?
    return false unless get_user_groups
    get_user_groups.include?('barito-superadmin')
  end
end
