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
    scope.where(:id => record.id).exists?
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
    if Figaro.env.enable_cas_integration == 'true'
      gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
      return true if Group.where(name: gate_groups).count > 0
    else
      return true if user.groups.count > 0
    end
  end
end
