class Art < ApplicationRecord
    belongs_to :user, optional: true
    has_many :subscribers, dependent: :destroy
    has_one_attached :featured_image
    has_rich_text :description

    validates :name, presence: true
    validates :inventory_count, numericality: { greater_than_or_equal_to: 0 }
    validates :met_object_id, uniqueness: { scope: :user_id }, allow_nil: true

    # Create an Art record scoped to a particular user based on a Met object hash.
    # Attaches the Met `primaryImage` to `featured_image` when available.
    def self.create_from_met_for_user!(object, user)
        met_id = object["objectID"].to_i
        name = object["title"] || "Met object #{met_id}"

        art = where(user_id: user.id, met_object_id: met_id).first_or_initialize
        art.name = name
        art.inventory_count ||= 0
        if object["objectURL"] && art.respond_to?(:description)
            art.description = object["objectURL"]
        end
        art.user = user
        art.save!

        if object["primaryImage"].present?
            begin
                require "open-uri"
                io = URI.open(object["primaryImage"], allow_redirections: :safe)
                filename = File.basename(URI.parse(object["primaryImage"]).path)
                art.featured_image.attach(io: io, filename: filename)
            rescue => e
                Rails.logger.debug("Art#create_from_met_for_user!: failed to attach image for met id #{met_id}: #{e.class} #{e.message}")
            end
        end

        art
    end
end
