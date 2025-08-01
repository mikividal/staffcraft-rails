class UpdateTechnicalMaturityFields < ActiveRecord::Migration[7.1]
  def change
    # Eliminar el campo actual
    remove_column :form_data, :technical_maturity, :string

    # Añadir los nuevos campos
    add_column :form_data, :has_internal_it_team, :boolean, default: false
    add_column :form_data, :team_skills_level, :string
    add_column :form_data, :team_available_hours, :string
  end
end
