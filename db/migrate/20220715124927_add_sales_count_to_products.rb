class AddSalesCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :sales_count, :integer, default:0
  end
end
