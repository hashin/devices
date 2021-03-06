class ActivationsController < ApplicationController
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  doorkeeper_for :create, :destroy, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_all_resources, only: %w(create)
  before_filter :find_owned_resources, only: %w(destroy)
  before_filter :find_accessible_resources, only: %w(destroy)
  before_filter :find_resource_by_activation_code
  before_filter :already_activated, only: %w(create)

  def create
    @device.activated_at = Time.now
    @device.resource_owner_id = current_user.id
    if @device.save
      render json: @device, status: 201, location: DeviceDecorator.decorate(@device).uri
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def destroy
    @device.activated_at = nil
    @device.save
    render json: @device
  end

  private

  def find_all_resources
    @devices = Device.all
  end

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_accessible_resources
    # TODO there is a bug in mongoid that does not let you use the #in method
    doorkeeper_token.device_ids.each { |id| @devices = @devices.or(id: id) } if !doorkeeper_token.device_ids.empty?
  end

  def find_resource_by_activation_code
    @device = @devices.find_by(activation_code: params[:activation_code] || params[:id])
  end

  def already_activated
    error = 'notifications.resource.already_activated'
    render_422(error, I18n.t(error)) if @device.activated_at
  end

  def document_not_found
    render_404 'notifications.activation.not_found'
  end
end
