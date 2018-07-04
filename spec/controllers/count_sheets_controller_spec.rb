require "rails_helper"

describe CountSheetsController, type: :controller do
  let(:open_reconciliation) { inventory_reconciliations(:open_reconciliation) }
  let(:flip_flop_bin) { bins(:flip_flop_bin) }
  let(:deleted_bin) { bins(:deleted_bin) }
  let(:empty_bin) { bins(:empty_bin) }

  let(:in_progress_reconciliation) { inventory_reconciliations(:in_progress_reconciliation) }
  let(:flip_flop_count_sheet) { count_sheets(:flip_flop_count_sheet) }
  let(:small_flip_flops_count_sheet_detail) { count_sheet_details(:small_flip_flops_count_sheet_detail) }
  let(:large_flip_flops_count_sheet_detail) { count_sheet_details(:large_flip_flops_count_sheet_detail) }

  before { signed_in_user :root }

  describe "GET index" do
    it "creates count sheets for bins that don't have count sheets yet" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      sheet = open_reconciliation.count_sheets.where(bin: flip_flop_bin).first
      expect(sheet).to be_present
      expect(flip_flop_bin.bin_items.size).to_not be_zero
      expect(flip_flop_bin.bin_items.pluck(:item_id).sort).to eq(sheet.count_sheet_details.pluck(:item_id).sort)
    end

    it "doesn't create count sheets for deleted bins" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: deleted_bin).first).to be_blank
    end

    it "doesn't create count sheets for empty bins" do
      get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
      expect(open_reconciliation.count_sheets.where(bin: empty_bin).first).to be_blank
    end

    context "with views" do
      render_views

      it "displays the count sheets" do
        get :index, params: { inventory_reconciliation_id: open_reconciliation.id.to_s }
        expect(response.body).to have_selector("td", text: flip_flop_bin.label)
      end
    end
  end

  describe "PUT update" do
    it "allows saving values for the count sheet" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows saving additional columns for the count sheet" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux", "New Counter"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2 3),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4 5)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux", "New Counter"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2, 3])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4, 5])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows deleting columns for the count sheet by leaving them out" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        save: "Save",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        counter_names: ["Foo Bar"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "",
          large_flip_flops_count_sheet_detail.id.to_s => ""
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar"])
      expect(flip_flop_count_sheet.complete).to be_falsey
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3])
      expect(small_flip_flops_count_sheet_detail.final_count).to be_nil
      expect(large_flip_flops_count_sheet_detail.final_count).to be_nil
    end

    it "allows marking the count sheet as completed" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        complete: "Complete",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "5",
          large_flip_flops_count_sheet_detail.id.to_s => "6"
        }
      }

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_truthy
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to eq(5)
      expect(large_flip_flops_count_sheet_detail.final_count).to eq(6)
    end

    it "blocks marking the count sheet complete if missing final counts" do
      expect do
        put :update, params: {
          id: flip_flop_count_sheet.id.to_s,
          inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
          complete: "Complete",
          counter_names: ["Foo Bar", "Baz Qux"],
          counts: {
            small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
            large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
          },
          final_counts: {
            small_flip_flops_count_sheet_detail.id.to_s => "5",
            large_flip_flops_count_sheet_detail.id.to_s => ""
          }
        }
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "blocks saving the count sheet once it is completed" do
      put :update, params: {
        id: flip_flop_count_sheet.id.to_s,
        inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
        complete: "Complete",
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          small_flip_flops_count_sheet_detail.id.to_s => %w(1 2),
          large_flip_flops_count_sheet_detail.id.to_s => %w(3 4)
        },
        final_counts: {
          small_flip_flops_count_sheet_detail.id.to_s => "5",
          large_flip_flops_count_sheet_detail.id.to_s => "6"
        }
      }

      expect do
        put :update, params: {
          id: flip_flop_count_sheet.id.to_s,
          inventory_reconciliation_id: in_progress_reconciliation.id.to_s,
          save: "Save",
          counter_names: ["Foos Bars", "Bazs Quxs"],
          counts: {
            small_flip_flops_count_sheet_detail.id.to_s => %w(3 5),
            large_flip_flops_count_sheet_detail.id.to_s => %w(8 2)
          },
          final_counts: {
            small_flip_flops_count_sheet_detail.id.to_s => "4",
            large_flip_flops_count_sheet_detail.id.to_s => "5"
          }
        }
      end.to raise_error(PermissionError)

      flip_flop_count_sheet.reload
      small_flip_flops_count_sheet_detail.reload
      large_flip_flops_count_sheet_detail.reload
      expect(flip_flop_count_sheet.counter_names).to eq(["Foo Bar", "Baz Qux"])
      expect(flip_flop_count_sheet.complete).to be_truthy
      expect(small_flip_flops_count_sheet_detail.counts).to eq([1, 2])
      expect(large_flip_flops_count_sheet_detail.counts).to eq([3, 4])
      expect(small_flip_flops_count_sheet_detail.final_count).to eq(5)
      expect(large_flip_flops_count_sheet_detail.final_count).to eq(6)
    end
  end
end