require "rails_helper"

describe User, type: :model do
  let(:root) { users(:root) }
  let(:acme_root) { users(:acme_root) }
  let(:acme_normal) { users(:acme_normal) }
  let(:foo_inc_root) { users(:foo_inc_root) }

  let(:acme) { organizations(:acme) }
  let(:foo_inc) { organizations(:foo_inc) }

  describe "#organizations_with_access" do
    it "returns all orgs for super admin" do
      expect(root.organizations_with_access).to match_array(Organization.all)
    end

    it "returns orgs you have access to for non super admins" do
      expect(acme_root.organizations_with_access).to match_array(acme)
      expect(acme_normal.organizations_with_access).to match_array(acme)
      expect(foo_inc_root.organizations_with_access).to match_array(foo_inc)
    end
  end

  describe "#super_admin?" do
    it "tells if the user is an admin for all of the site" do
      expect(root).to be_a_super_admin

      expect(acme_root).to_not be_a_super_admin
      expect(acme_normal).to_not be_a_super_admin
    end
  end

  describe "#admin?" do
    it "tells if the user is an admin at any organization" do
      expect(root.admin?).to be_truthy
      expect(acme_root.admin?).to be_truthy
      expect(foo_inc_root.admin?).to be_truthy

      expect(acme_normal.admin?).to be_falsey
    end
  end

  describe "#admin_at?" do
    it "tells if the user is an admin for a particular organization" do
      expect(root.admin_at?(acme)).to be_truthy
      expect(acme_root.admin_at?(acme)).to be_truthy
      expect(foo_inc_root.admin_at?(foo_inc)).to be_truthy

      expect(acme_normal.admin_at?(acme)).to be_falsey
      expect(acme_root.admin_at?(foo_inc)).to be_falsey
      expect(foo_inc_root.admin_at?(acme)).to be_falsey
    end
  end

  describe "#member_at?" do
    it "tells if the user is a member of a particular organization" do
      expect(acme_root.member_at?(acme)).to be_truthy
      expect(acme_normal.member_at?(acme)).to be_truthy
      expect(foo_inc_root.member_at?(foo_inc)).to be_truthy

      expect(root.member_at?(acme)).to be_falsey
      expect(root.member_at?(foo_inc)).to be_falsey
      expect(acme_root.member_at?(foo_inc)).to be_falsey
      expect(acme_normal.member_at?(foo_inc)).to be_falsey
      expect(foo_inc_root.member_at?(acme)).to be_falsey
    end
  end

  describe "User::OrderManipulator" do
    describe "#can_edit_order?" do
      context "when order has not been shipped" do
        let(:order) { orders(:acme_order) }
        it "permits super_admin to edit" do
          expect(root.can_edit_order?(order)).to be_truthy
        end
        it "permits acme_root to edit" do
          expect(acme_root.can_edit_order?(order)).to be_truthy
        end
        it "permits acme_normal to edit" do
          expect(acme_normal.can_edit_order?(order)).to be_truthy
        end
        it "denies non-org users to edit" do
          expect(foo_inc_root.can_edit_order?(order)).to be_falsy
        end
      end
      context "when order has been shipped" do
        let(:order) { orders(:acme_submitted_order) }
        it "permits super_admin to edit" do
          expect(root.can_edit_order?(order)).to be_truthy
        end
        it "denies acme_root to edit" do
          expect(acme_root.can_edit_order?(order)).to be_falsy
        end
        it "denies acme_normal to edit" do
          expect(acme_normal.can_edit_order?(order)).to be_falsy
        end
        it "denies non-org users to edit" do
          expect(foo_inc_root.can_edit_order?(order)).to be_falsy
        end
      end
    end
    describe "#can_view_order?" do
      context "when order has not been shipped" do
        let(:order) { orders(:acme_order) }
        it "permits super_admin to view" do
          expect(root.can_view_order?(order)).to be_truthy
        end
        it "permits acme_root to view" do
          expect(acme_root.can_view_order?(order)).to be_truthy
        end
        it "permits acme_normal to view" do
          expect(acme_normal.can_view_order?(order)).to be_truthy
        end
        it "denies non-org users to view" do
          expect(foo_inc_root.can_view_order?(order)).to be_falsy
        end
      end
      context "when order has been shipped" do
        let(:order) { orders(:acme_submitted_order) }
        it "permits super_admin to view" do
          expect(root.can_view_order?(order)).to be_truthy
        end
        it "denies acme_root to view" do
          expect(acme_root.can_view_order?(order)).to be_truthy
        end
        it "denies acme_normal to view" do
          expect(acme_normal.can_view_order?(order)).to be_truthy
        end
        it "denies non-org users to view" do
          expect(foo_inc_root.can_view_order?(order)).to be_falsy
        end
      end
    end
  end
end
