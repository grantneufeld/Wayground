# encoding: utf-8

module Wayground
  module Democracy

    # Generate data records (currently, just ballots) for an election.
    class ElectionBuilder
      attr_reader :election, :term_start_on, :term_end_on

      # You must pass in an existing :election.
      # You may also pass in dates for :term_start_on and :term_end_on.
      def initialize(params)
        @election = params[:election]
        @term_start_on = params[:term_start_on]
        @term_end_on = params[:term_end_on]
      end

      def generate_ballots
        offices_to_add_ballots_for.each do |office|
          ballot = @election.ballots.new(term_start_on: @term_start_on, term_end_on: @term_end_on)
          ballot.office = office
          #ballot.save!
        end
        @election.save!
      end

      # protected

      def offices_to_add_ballots_for
        if @election.ballots.count > 0
          # there are existing ballots, so don’t generate new ones for the same offices
          offices_without_ballots
        else
          # need to add every office
          offices_for_level
        end
      end

      def offices_without_ballots
        offices_to_add = []
        offices_for_level.each do |office|
          ballot_count = @election.ballots.where(office_id: office.id).count
          unless ballot_count > 0
            offices_to_add << office
          end
        end
        offices_to_add
      end

      def offices_for_level
        if @term_start_on
          @election.level.offices.active_on(@term_start_on)
        else
          @election.level.offices
        end
      end

    end

  end
end
