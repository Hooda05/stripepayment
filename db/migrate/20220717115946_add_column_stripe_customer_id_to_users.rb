class AddColumnStripeCustomerIdToUsers < ActiveRecord::Migration[6.1]
  def change
     add_column :users, :stripe_customer_id, :string
  end
end
