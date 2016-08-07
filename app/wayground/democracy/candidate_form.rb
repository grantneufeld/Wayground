require 'filename_validator'
require 'person'

module Wayground
  module Democracy

    # Process parameters passed in for a Candidate.
    class CandidateForm
      include ::Virtus.model
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations

      # ATTRIBUTES

      attr_accessor :ballot

      def candidate
        if !@candidate && ballot
          @candidate = ballot.candidates.build(candidate_attributes)
          @candidate.ballot = ballot
        end
        @candidate
      end

      def candidate=(value)
        @candidate = value
        self.ballot = @candidate.ballot if @candidate
        attrs_from_candidate
      end

      def person
        @candidate.person ||= Person.new(person_attributes) if candidate
      end

      def person=(value)
        candidate.person = value
        attrs_from_person
      end

      attribute :filename,     ::String
      attribute :name,         ::String
      attribute :is_rumoured,  ::Integer, default: false
      attribute :is_confirmed, ::Integer, default: false
      attribute :is_incumbent, ::Integer, default: false
      attribute :is_leader,    ::Integer, default: false
      attribute :is_acclaimed, ::Integer, default: false
      attribute :is_elected,   ::Integer, default: false
      attribute :announced_on, ::Date
      attribute :quit_on,      ::Date
      attribute :vote_count,   ::Integer, default: 0
      attribute :bio,          ::String
      attribute :party_id,     ::Integer, default: nil

      # VALIDATIONS

      # commented validations are handled in the candidate or person models:
      validates :ballot, presence: true
      validates :name, presence: true, format: { with: /\A[^\r\n\t<>&]+\z/ }
      # candidate - :name, uniqueness: { scope: :ballot_id }
      validates :filename, presence: true, filename: true
      # candidate - :filename, uniqueness: { scope: :ballot_id }
      # person    - :filename, uniqueness: { scope: :ballot_id }
      validate :validate_dates
      validate :validate_persisted_objects
      # Candidate:
      # :person_id, uniqueness: { scope: :ballot_id }

      def validate_dates
        if quit_on.present? && announced_on.present? && quit_on.to_date < announced_on.to_date
          errors.add(:quit_on, 'must be on or after the date candidacy was announced on')
        end
      end

      def validate_persisted_objects
        if !candidate
          errors.add(:candidate, 'failed to create record')
        elsif !candidate.valid?
          add_errors_from(candidate.errors.messages)
        end
        if !person
          errors.add(:person, 'failed to create record')
        elsif !person.valid?
          add_errors_from(person.errors.messages)
        end
      end

      # PUBLIC METHODS

      def attributes=(params)
        if params
          self.filename     = params['filename']     if params.key?('filename')
          self.name         = params['name']         if params.key?('name')
          self.is_rumoured  = params['is_rumoured']  if params.key?('is_rumoured')
          self.is_confirmed = params['is_confirmed'] if params.key?('is_confirmed')
          self.is_incumbent = params['is_incumbent'] if params.key?('is_incumbent')
          self.is_leader    = params['is_leader']    if params.key?('is_leader')
          self.is_acclaimed = params['is_acclaimed'] if params.key?('is_acclaimed')
          self.is_elected   = params['is_elected']   if params.key?('is_elected')
          self.announced_on = params['announced_on'] if params.key?('announced_on')
          self.quit_on      = params['quit_on']      if params.key?('quit_on')
          self.vote_count   = params['vote_count']   if params.key?('vote_count')
          self.bio          = params['bio']          if params.key?('bio')
          self.party_id     = params['party_id']     if params.key?('party_id')
          self.filename = name.strip.downcase.gsub(/ +/, '_') if name && filename.blank?
        end
      end

      def save
        if valid?
          persist
        else
          false
        end
      end

      protected

      def add_errors_from(messages)
        messages.each do |key, value|
          value.each do |msg|
            errors.add(key, msg)
          end
        end
      end

      def attrs_from_candidate
        self.filename ||= @candidate.filename
        self.name ||= @candidate.name
        self.is_rumoured = @candidate.is_rumoured
        self.is_confirmed = @candidate.is_confirmed
        self.is_incumbent = @candidate.is_incumbent
        self.is_leader = @candidate.is_leader
        self.is_acclaimed = @candidate.is_acclaimed
        self.is_elected = @candidate.is_elected
        self.announced_on ||= @candidate.announced_on
        self.quit_on ||= @candidate.quit_on
        self.vote_count = @candidate.vote_count if !vote_count || vote_count.zero?
        self.bio ||= (person ? person.bio : nil)
        self.party_id ||= @candidate.party_id
      end

      def attrs_from_person
        self.filename = person.filename if filename.blank?
        self.name = person.fullname if name.blank?
        self.bio = person.bio if bio.blank?
      end

      def persist
        candidate.attributes = candidate_attributes
        person.filename ||= filename if filename.present?
        person.fullname ||= name if name.present?
        person.bio = bio if bio.present?
        candidate.save && person.save
      end

      def candidate_attributes
        {
          filename: filename, name: name,
          is_rumoured: is_rumoured, is_confirmed: is_confirmed, is_incumbent: is_incumbent,
          is_leader: is_leader, is_acclaimed: is_acclaimed, is_elected: is_elected,
          announced_on: announced_on, quit_on: quit_on, vote_count: vote_count,
          party_id: party_id
        }
      end

      def person_attributes
        { fullname: name || @candidate.name, filename: filename || @candidate.filename, bio: bio }
      end
    end

  end
end
