module Merger

  # TODO: Transactionalize mergers so failures can rollback any changes

  # Merges two instances of a class.
  class Base
    attr_reader :source

    def initialize(source)
      @source = source
    end

    # Merge the values from the source into the destination,
    # move this source’s associated records to the destination,
    # and delete the source.
    # Returns a hash of any conflicts between the source and
    # destination fields’ values.
    def merge_into!(destination)
      conflicts = merge_fields_into(destination)
      merge_authorities_into(destination)
      merge_external_links_into(destination)
      merge_tags_into(destination)
      merge_sourced_items_into(destination)
      merge_versions_into(destination)
      @source.delete
      conflicts
    end

    # Merge the values of the source into the destination.
    def merge_fields_into(destination)
      destination.save!
      {}
    end

    # Move non-duplicate authority records associated with the source to the destination.
    # Merge the permissions of any duplicates, then remove the source duplicate.
    def merge_authorities_into(destination)
      @source.authorities.each do |authority|
        duplicate_authority = destination.authorities.where(user_id: authority.user.id).first
        if duplicate_authority
          # this merge will delete the authority,
          # keeping the one for the destination
          authority.merge_into!(duplicate_authority)
        end
      end
      @source.authorities.update_all(item_id: destination.id)
    end

    # Move non-duplicate external link records associated with this event to another event.
    def merge_external_links_into(destination)
      @source.external_links.each do |external_link|
        if destination.external_links.where(url: external_link.url).first
          # dispose of the link if it has a duplicate in the destination
          external_link.delete
        end
      end
      # we got rid of duplicates, now move over any remaining external links
      @source.external_links.update_all(item_id: destination.id)
    end

    # Move non-duplicate tags records associated with this item to another item.
    def merge_tags_into(destination)
      @source.tags.each do |tag|
        if destination.tags.where(tag: tag.tag).first
          # dispose of the tag if it has a duplicate in the destination
          tag.delete
        end
      end
      # we got rid of duplicates, now move over any remaining tags
      @source.tags.update_all(item_id: destination.id)
    end

    # Move all of the sourced item records associated with the source
    # to the destination.
    def merge_sourced_items_into(destination)
      @source.sourced_items.update_all(item_id: destination.id, has_local_modifications: true)
    end

    # Move all of the versions records associated with the source to the destination.
    def merge_versions_into(destination)
      @source.versions.update_all(item_id: destination.id)
    end

  end

  # Merges two Events.
  class EventMerger < Base

    # Merge the field values of the source Event into the destination Event.
    # This is a “Big Ugly Method” that would probably benefit from some
    # clever coding to DRY it up. But, I’m kind of tired as I write this,
    # so I’m leaving it messy (though functional).
    def merge_fields_into(destination)
      conflicts = {}
      destination.user ||= @source.user
      if @source.start_at? && (@source.start_at != destination.start_at)
        if destination.start_at?
          conflicts[:start_at] = @source.start_at
        else
          destination.start_at = @source.start_at
        end
      end
      if @source.end_at? && (@source.end_at != destination.end_at)
        if destination.end_at?
          conflicts[:end_at] = @source.end_at
        else
          destination.end_at = @source.end_at
        end
      end
      if @source.timezone? && (@source.timezone != destination.timezone)
        if destination.timezone?
          conflicts[:timezone] = @source.timezone
        else
          destination.timezone = @source.timezone
        end
      end
      destination.is_allday ||= @source.is_allday
      destination.is_draft &&= @source.is_draft
      destination.is_approved ||= @source.is_approved
      destination.is_wheelchair_accessible ||= @source.is_wheelchair_accessible
      destination.is_adults_only ||= @source.is_adults_only
      destination.is_tentative &&= @source.is_tentative
      destination.is_cancelled ||= @source.is_cancelled
      destination.is_featured ||= @source.is_featured
      if @source.title? && (@source.title != destination.title)
        if destination.title?
          conflicts[:title] = @source.title
        else
          destination.title = @source.title
        end
      end
      if @source.description? && (@source.description != destination.description)
        if destination.description?
          conflicts[:description] = @source.description
        else
          destination.description = @source.description
        end
      end
      if @source.content? && (@source.content != destination.content)
        if destination.content?
          conflicts[:content] = @source.content
        else
          destination.content = @source.content
        end
      end
      if @source.organizer? && (@source.organizer != destination.organizer)
        if destination.organizer?
          conflicts[:organizer] = @source.organizer
        else
          destination.organizer = @source.organizer
        end
      end
      if @source.organizer_url? && (@source.organizer_url != destination.organizer_url)
        if destination.organizer_url?
          conflicts[:organizer_url] = @source.organizer_url
        else
          destination.organizer_url = @source.organizer_url
        end
      end
      if @source.location? && (@source.location != destination.location)
        if destination.location?
          conflicts[:location] = @source.location
        else
          destination.location = @source.location
        end
      end
      if @source.address? && (@source.address != destination.address)
        if destination.address?
          conflicts[:address] = @source.address
        else
          destination.address = @source.address
        end
      end
      if @source.city? && (@source.city != destination.city)
        if destination.city?
          conflicts[:city] = @source.city
        else
          destination.city = @source.city
        end
      end
      if @source.province? && (@source.province != destination.province)
        if destination.province?
          conflicts[:province] = @source.province
        else
          destination.province = @source.province
        end
      end
      if @source.country? && (@source.country != destination.country)
        if destination.country?
          conflicts[:country] = @source.country
        else
          destination.country = @source.country
        end
      end
      if @source.location_url? && (@source.location_url != destination.location_url)
        if destination.location_url?
          conflicts[:location_url] = @source.location_url
        else
          destination.location_url = @source.location_url
        end
      end
      destination.save!
      conflicts
    end

  end

end
