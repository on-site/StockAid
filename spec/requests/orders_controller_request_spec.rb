require "rails_helper"

describe OrdersController, type: :request do
  let(:root) { users(:root) }
  let(:org_admin) { users(:view_check_root) }
  let(:org_user) { users(:view_check_normal) }
  let(:non_org_user) { users(:foo_inc_root) }

  describe "#edit" do
    context "before order has been submitted" do
      let(:order) { orders(:view_check_unsubmitted_order) }
      subject { get edit_order_path(order) }

      context "when logged in as super_admin" do
        before { sign_in root }
        it "confirm order view is shown" do
          expect(subject).to render_template("orders/status/confirm_order")
        end
      end

      context "when logged in as order's organization admin user" do
        before { sign_in org_admin }
        it "confirm order view is shown" do
          expect(subject).to render_template("orders/status/confirm_order")
        end
      end

      context "when logged in as order's organization normal user" do
        before { sign_in org_user }
        it "confirm order view is shown" do
          expect(subject).to render_template("orders/status/confirm_order")
        end
      end

      context "when logged in as another organization user" do
        before { sign_in non_org_user }
        it "redirects to order show" do
          expect(subject).to redirect_to(order_path(order))
        end
      end
    end

    context "after order has been submitted" do
      let(:order) { orders(:view_check_submitted_order) }
      subject { get edit_order_path(order) }

      context "when logged in as super_admin" do
        before { sign_in root }
        it "edit view is shown" do
          expect(subject).to render_template("edit")
        end
      end

      context "when logged in as order's organization admin user" do
        before { sign_in org_admin }
        it "redirects to order show" do
          expect(subject).to redirect_to(order_path(order))
        end
      end

      context "when logged in as order's organization normal user" do
        before { sign_in org_user }
        it "redirects to order show" do
          expect(subject).to redirect_to(order_path(order))
        end
      end

      context "when logged in as another organization user" do
        before { sign_in non_org_user }
        it "redirects to order show" do
          expect(subject).to redirect_to(order_path(order))
        end
      end
    end
  end

  describe "#show" do
    let(:order) { orders(:view_check_submitted_order) }
    subject { get order_path(order) }

    context "when logged in as super_admin" do
      before { sign_in root }
      it "show view is shown" do
        expect(subject).to render_template("show")
      end
    end

    context "when logged in as order's organization admin user" do
      before { sign_in org_admin }
      it "show view is shown" do
        expect(subject).to render_template("show")
      end
    end

    context "when logged in as order's organization normal user" do
      before { sign_in org_user }
      it "redirects to order show" do
        expect(subject).to render_template("show")
      end
    end

    context "when logged in as another organization user" do
      before { sign_in non_org_user }
      it "redirects to order show" do
        expect(subject).to redirect_to(orders_path)
      end
    end
  end
end
