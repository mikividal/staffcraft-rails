class AddExistingToolsDataToFormData < ActiveRecord::Migration[7.1]
  def change
    add_column :form_data, :existing_tools_data, :text

    # Opcional: eliminar campos antiguos si no los usas más
    # remove_column :form_data, :existing_tools_stack, :string
    # remove_column :form_data, :existing_tools_custom, :string
  end
end
