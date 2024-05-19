class Users::Create < ActiveInteraction::Base
  hash :params do
    string :name
    string :surname
    string :patronymic
    string :fullname
    string :email
    string :nationality
    string :country
    string :gender
    string :skills

    integer :age

    array :interests
  end

  validates params[:name], params[:patronymic], params[:email],
            params[:age], params[:nationality], params[:country],
            params[:gender], presence: true
  validate  :email_validation_uniqueness
  validates params[:age], length: { minimum: User::MIN_AGE, maximum: User::MAX_AGE, message: 'Please enter age from 1 to 90' }
  validates params[:gender], inclusion: { in: %w[male female], message: 'Please enter your gender as male or female' }

  attr_reader :user

  private

  def execute
    @user = User.create!(create_params)
    return errors.merge(@user.errors) if @user.invalid?

    create_interest
    create_skil
  end

  def create_params
    user_params.merge(another_fullname: another_fullname)
  end

  def user_params
    params.except(:interests)
  end

  def another_fullname
    "#{params[:surname]} #{params[:name]} #{params[:patronymic]}"
  end

  def create_interest
    Interest.includes(:user).where(name: params[:interests]).each do |interest|
      @user.user_interests.create(interest: interest)
    end
  end

  def create_skil
    params[:skills].split(',').each do |skil|
      skil = Skil.find(name: skil)
      next if skil.nil?

      @user.user_skils.create(skil: skil)
    end
  end

  def email_validation_uniqueness
    errors.add(:email, 'A user with that email already exists') if User.exists?(email: params[:email])
  end
end
