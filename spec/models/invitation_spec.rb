require "rails_helper"

RSpec.describe Invitation do

  def create_new_user
    User.create(email: "rookie@example.com")
  end

  def create_team
    Team.create(name: "A fine team")
  end

  def new_invite_for(new_user, team = nil)
    Invitation.new(team: team, user: new_user)
  end

  describe "callbacks" do
    describe "after_save" do
      context "with valid data" do
        it "invites the user" do
          new_user = create_new_user
          team = create_team
          invitation = new_invite_for(new_user, team)

          invitation.save

          expect(new_user).to be_invited
        end
      end

      context "with invalid data" do
        # before do
        #   invitation.team = nil
        #   invitation.save
        # end

        it "does not save the invitation" do
          new_user = create_new_user
          invalid_invitation = new_invite_for(new_user)

          invalid_invitation.save

          expect(invalid_invitation).not_to be_valid
          expect(invalid_invitation).to be_new_record
        end

        it "does not mark the user as invited" do
          new_user = create_new_user
          # No exercise to perform
          expect(new_user).not_to be_invited
        end
      end
    end
  end

  describe "#event_log_statement" do
    context "when the record is saved" do
      # before do
      #   invitation.save
      # end

      it "include the name of the team" do
        new_user = create_new_user
        team = create_team
        invitation = new_invite_for(new_user, team)

        invitation.save

        log_statement = invitation.event_log_statement
        expect(log_statement).to include("A fine team")
      end

      it "include the email of the invitee" do
        new_user = create_new_user
        team = create_team
        invitation = new_invite_for(new_user, team)

        invitation.save

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end
    end

    context "when the record is not saved but valid" do
      it "includes the name of the team" do
        new_user = create_new_user
        team = create_team
        invitation = new_invite_for(new_user, team)

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("A fine team")
      end

      it "includes the email of the invitee" do
        new_user = create_new_user
        team = create_team
        invitation = new_invite_for(new_user, team)

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end

      it "includes the word 'PENDING'" do
        new_user = create_new_user
        team = create_team
        invitation = new_invite_for(new_user, team)

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("PENDING")
      end
    end

    context "when the record is not saved and not valid" do
      it "includes INVALID" do
        new_user = create_new_user
        invitation = new_invite_for(new_user)

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("INVALID")
      end
    end
  end
end
